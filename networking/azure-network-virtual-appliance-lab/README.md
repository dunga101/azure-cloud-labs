# Azure Network Virtual Appliance (NVA) Routing Lab

## Overview

This lab simulates a cloud-based Network Virtual Appliance (NVA) deployment in Microsoft Azure using Ubuntu Linux as a software router.

The objective was to design and validate segmented network routing, security controls, packet forwarding, NAT behavior, and traffic steering using Azure-native networking components.

This project demonstrates practical cloud infrastructure engineering and troubleshooting beyond portal-based deployments.

## Architecture Summary

The lab was built using a segmented Azure Virtual Network with a DMZ subnet, an internal subnet, a Linux router VM, and an internal-only client VM.

```text
Internet
   |
Azure Public IP
   |
vm-router
Ubuntu Linux NVA
10.10.1.4
   |
Azure VNet: 10.10.0.0/16
   |-- dmz-subnet:      10.10.1.0/24
   |-- internal-subnet: 10.10.2.0/24
          |
       vm-client
       10.10.2.5
```

## Technologies Used

- Microsoft Azure
- Azure Virtual Network
- Azure Network Security Groups
- Azure Route Tables / User Defined Routes
- Azure Virtual Machines
- Azure Network Interface IP Forwarding
- Ubuntu Server 22.04
- Linux kernel IP forwarding
- iptables
- tcpdump
- Azure CLI
- SSH

## Lab Components

| Component | Name | Purpose |
|---|---|---|
| Resource Group | `rg_sb_eastus_314010_1_177876567238` | Sandbox resource container |
| VNet | `vnet-smarttrade` | Main network address space |
| DMZ Subnet | `dmz-subnet` | Router-facing subnet |
| Internal Subnet | `internal-subnet` | Protected workload subnet |
| Router VM | `vm-router` | Ubuntu-based software router / pseudo-NVA |
| Client VM | `vm-client` | Internal workload with no public IP |
| Public IP | `pip-router` | Internet-facing public IP for router |
| NSG | `nsg-router` | Inbound security controls |
| Route Table | `rt-internal` | UDR traffic steering toward virtual appliance |

## Network Addressing

| Network | CIDR |
|---|---|
| VNet | `10.10.0.0/16` |
| DMZ Subnet | `10.10.1.0/24` |
| Internal Subnet | `10.10.2.0/24` |
| Router Private IP | `10.10.1.4` |
| Client Private IP | `10.10.2.5` |
| Router Public IP | `20.124.227.236` |

## Security Rules

The router NSG allowed only the inbound ports relevant to administration and VPN ingress simulation.

| Rule | Port | Protocol | Purpose |
|---|---:|---|---|
| AllowSSH | 22 | TCP | Administrative SSH |
| AllowOpenVPN | 1194 | UDP | OpenVPN ingress simulation |
| AllowIKE | 500 | UDP | IPSec IKE |
| AllowNATT | 4500 | UDP | IPSec NAT Traversal |

## Routing Design

A User Defined Route was configured on the internal subnet:

```text
0.0.0.0/0 → Virtual Appliance → 10.10.1.4
```

This simulates traffic steering toward a network appliance, firewall, or VPN gateway.

## Router Configuration

The Ubuntu router VM was configured with:

- Linux kernel IP forwarding
- Azure NIC IP forwarding
- iptables forwarding rules
- iptables NAT masquerading
- tcpdump packet inspection

## Validation Performed

Successful validation included:

- Azure VNet and subnet deployment
- Router VM public/private connectivity
- Internal-only client VM deployment
- NSG rule creation for SSH, OpenVPN, IKE, and NAT-T
- Azure route table creation and subnet association
- Azure NIC IP forwarding enabled
- Linux kernel forwarding enabled
- iptables NAT configured
- Router internet connectivity validated with ICMP
- Packet capture performed using tcpdump

## Observed Limitation

A full dual-NIC NVA architecture was planned. However, the sandbox environment enforced an Azure Policy restriction that blocked VM mutation due to premium SSD policy enforcement during NIC attachment.

As a result, the design was adapted to a single-NIC software-router model while preserving the core routing, NAT, forwarding, route-table, and troubleshooting objectives.

The key troubleshooting conclusion was that the UDR was correctly associated and pointed to the virtual appliance, but packet capture on the router did not show client ICMP traffic arriving. This indicated the issue was upstream of the Linux router configuration, within the Azure fabric/sandbox behavior or platform constraints.

## Skills Demonstrated

- Azure networking design
- Segmented subnet architecture
- Network Virtual Appliance design concepts
- User Defined Route configuration
- NSG rule management
- Linux routing and NAT
- Packet-level troubleshooting
- Cloud routing validation
- VPN port/security awareness
- Practical infrastructure troubleshooting

## Screenshots

Screenshots are stored in the `screenshots/` directory.

Recommended screenshots:

1. Resource group overview
2. VNet topology
3. Route table
4. NSG inbound rules
5. Router VM network settings
6. Client VM network settings
7. Router NIC IP forwarding
