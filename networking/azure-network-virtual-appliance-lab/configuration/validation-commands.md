# Validation Commands

## Azure Inventory

```bash
echo "RG: $RG"

az network vnet show \
  -g "$RG" \
  -n vnet-smarttrade \
  --query "{name:name,addressSpace:addressSpace.addressPrefixes,subnets:subnets[].{name:name,prefix:addressPrefix}}" \
  -o json

az vm list -g "$RG" -d -o table

az network public-ip list -g "$RG" -o table
```

## Route Table Validation

```bash
az network route-table show \
  -g "$RG" \
  -n rt-internal \
  -o json

az network vnet subnet show \
  --resource-group "$RG" \
  --vnet-name vnet-smarttrade \
  --name internal-subnet \
  --query "{subnet:name, routeTable:routeTable.id}" \
  -o json
```

## NSG Validation

```bash
az network nsg rule list \
  -g "$RG" \
  --nsg-name nsg-router \
  -o table
```

## Router VM Validation

```bash
hostname
ip a
ip route
sysctl net.ipv4.ip_forward
sudo iptables -L
sudo iptables -t nat -L
ping -c 4 8.8.8.8
```

## Client VM Validation with Azure Run Command

```bash
az vm run-command invoke \
  --resource-group "$RG" \
  --name vm-client \
  --command-id RunShellScript \
  --scripts "ip a && ip route"

az vm run-command invoke \
  --resource-group "$RG" \
  --name vm-client \
  --command-id RunShellScript \
  --scripts "ping -c 4 8.8.8.8"
```

## Packet Capture on Router

```bash
sudo tcpdump -n icmp
```

## Cleanup

```bash
az group delete --name "$RG" --yes --no-wait
```
