#!/usr/bin/env bash

# Example variables for the Azure NVA Routing Lab.
# Source this file before running deploy.sh:
# source ./variables.example.sh

export RG="rg-sandbox-or-your-resource-group"
export LOCATION="eastus"

export VNET_NAME="vnet-smarttrade"
export VNET_CIDR="10.10.0.0/16"

export DMZ_SUBNET_NAME="dmz-subnet"
export DMZ_SUBNET_CIDR="10.10.1.0/24"

export INTERNAL_SUBNET_NAME="internal-subnet"
export INTERNAL_SUBNET_CIDR="10.10.2.0/24"

export NSG_ROUTER="nsg-router"
export PIP_ROUTER="pip-router"
export NIC_ROUTER="nic-router"

export ROUTER_VM="vm-router"
export CLIENT_VM="vm-client"
export ADMIN_USER="azureadmin"
export VM_SIZE="Standard_B1s"

export ROUTE_TABLE_INTERNAL="rt-internal"
export ROUTE_NAME_DEFAULT="default-to-router"
export ROUTER_PRIVATE_IP="10.10.1.4"
