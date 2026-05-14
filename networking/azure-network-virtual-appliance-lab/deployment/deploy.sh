#!/usr/bin/env bash
set -euo pipefail

# Azure Network Virtual Appliance Routing Lab Deployment Script
# Prerequisite:
#   az login
#   source ./variables.example.sh
#
# This script assumes the resource group already exists.
# For a personal subscription, create it first:
#   az group create --name "$RG" --location "$LOCATION"

echo "Deploying Azure NVA Routing Lab into resource group: $RG"

echo "Creating VNet and DMZ subnet..."
az network vnet create \
  --resource-group "$RG" \
  --name "$VNET_NAME" \
  --location "$LOCATION" \
  --address-prefix "$VNET_CIDR" \
  --subnet-name "$DMZ_SUBNET_NAME" \
  --subnet-prefix "$DMZ_SUBNET_CIDR"

echo "Creating internal subnet..."
az network vnet subnet create \
  --resource-group "$RG" \
  --vnet-name "$VNET_NAME" \
  --name "$INTERNAL_SUBNET_NAME" \
  --address-prefix "$INTERNAL_SUBNET_CIDR"

echo "Creating router NSG..."
az network nsg create \
  --resource-group "$RG" \
  --name "$NSG_ROUTER" \
  --location "$LOCATION"

echo "Creating router NSG rules..."
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG_ROUTER" \
  --name AllowSSH \
  --priority 100 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 22

az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG_ROUTER" \
  --name AllowOpenVPN \
  --priority 110 \
  --access Allow \
  --protocol Udp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 1194

az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG_ROUTER" \
  --name AllowIKE \
  --priority 120 \
  --access Allow \
  --protocol Udp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 500

az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG_ROUTER" \
  --name AllowNATT \
  --priority 130 \
  --access Allow \
  --protocol Udp \
  --direction Inbound \
  --source-address-prefixes "*" \
  --destination-port-ranges 4500

echo "Creating router public IP..."
az network public-ip create \
  --resource-group "$RG" \
  --name "$PIP_ROUTER" \
  --location "$LOCATION" \
  --sku Standard \
  --allocation-method Static

echo "Creating router NIC..."
az network nic create \
  --resource-group "$RG" \
  --name "$NIC_ROUTER" \
  --location "$LOCATION" \
  --vnet-name "$VNET_NAME" \
  --subnet "$DMZ_SUBNET_NAME" \
  --network-security-group "$NSG_ROUTER" \
  --public-ip-address "$PIP_ROUTER"

echo "Creating router VM..."
az vm create \
  --resource-group "$RG" \
  --name "$ROUTER_VM" \
  --location "$LOCATION" \
  --nics "$NIC_ROUTER" \
  --image Ubuntu2204 \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --public-ip-sku Standard

echo "Enabling Azure NIC IP forwarding..."
az network nic update \
  --resource-group "$RG" \
  --name "$NIC_ROUTER" \
  --ip-forwarding true

echo "Creating internal client VM with no public IP..."
az vm create \
  --resource-group "$RG" \
  --name "$CLIENT_VM" \
  --location "$LOCATION" \
  --image Ubuntu2204 \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --vnet-name "$VNET_NAME" \
  --subnet "$INTERNAL_SUBNET_NAME" \
  --public-ip-address ""

echo "Creating internal route table..."
az network route-table create \
  --resource-group "$RG" \
  --name "$ROUTE_TABLE_INTERNAL" \
  --location "$LOCATION"

echo "Adding default route to virtual appliance..."
az network route-table route create \
  --resource-group "$RG" \
  --route-table-name "$ROUTE_TABLE_INTERNAL" \
  --name "$ROUTE_NAME_DEFAULT" \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address "$ROUTER_PRIVATE_IP"

echo "Associating route table with internal subnet..."
az network vnet subnet update \
  --resource-group "$RG" \
  --vnet-name "$VNET_NAME" \
  --name "$INTERNAL_SUBNET_NAME" \
  --route-table "$ROUTE_TABLE_INTERNAL"

echo "Deployment complete."
echo "Router public IP:"
az network public-ip show \
  --resource-group "$RG" \
  --name "$PIP_ROUTER" \
  --query ipAddress \
  -o tsv
