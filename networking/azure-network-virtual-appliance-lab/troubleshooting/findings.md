# Troubleshooting Findings

## Objective

Validate Azure traffic steering through a Linux-based Network Virtual Appliance pattern using UDRs, Linux forwarding, and NAT.

## What Worked

- VNet created with segmented subnets:
  - `dmz-subnet` — `10.10.1.0/24`
  - `internal-subnet` — `10.10.2.0/24`
- Router VM deployed with public IP and private IP `10.10.1.4`.
- Client VM deployed in internal subnet with private IP `10.10.2.5` and no public IP.
- NSG rules created for:
  - SSH TCP 22
  - OpenVPN UDP 1194
  - IPSec IKE UDP 500
  - IPSec NAT-T UDP 4500
- Azure NIC IP forwarding enabled on router NIC.
- Linux kernel IP forwarding enabled.
- iptables NAT masquerade configured.
- Router VM successfully reached the internet.
- Route table associated successfully to internal subnet.
- UDR successfully created:
  - `0.0.0.0/0`
  - next hop type: `VirtualAppliance`
  - next hop IP: `10.10.1.4`

## Important Observation

After associating the UDR, packet capture on the router did not show ICMP packets from the client VM reaching the router.

This indicated that the issue was upstream of Linux routing, NAT, and firewall configuration.

## Likely Root Cause

A full dual-NIC NVA architecture was planned, but the sandbox environment blocked VM mutation when attempting to attach a second NIC.

The error observed was policy-related:

```text
RequestDisallowedByPolicy
Premium SSD is not allowed for Virtual Machines
```

Because the dual-NIC design could not be completed in the sandbox, the lab was adapted to a single-NIC NVA model.

## Troubleshooting Method Used

1. Verified router internet connectivity.
2. Verified Linux IP forwarding.
3. Verified Azure NIC IP forwarding.
4. Verified iptables forwarding and NAT.
5. Verified UDR creation.
6. Verified UDR subnet association.
7. Used `tcpdump` to determine whether traffic reached the router.
8. Concluded that missing packets at the router indicated an Azure fabric/sandbox limitation rather than an iptables or Linux routing problem.

## Key Learning

When troubleshooting cloud network appliances, validate both the guest OS and cloud fabric layers:

- Guest OS forwarding
- Cloud NIC forwarding
- Route table association
- Next-hop type
- NSG rules
- Packet capture at the appliance
- Platform policy constraints
- Asymmetric routing or unsupported topology issues

## Interview-Ready Summary

I built an Azure-based network lab with segmented subnets, a Linux virtual router acting as a pseudo network appliance, Azure NIC forwarding, Linux kernel forwarding, iptables NAT, NSG VPN ingress rules, and UDR-based traffic steering. When transit traffic failed, I used route validation and packet capture to isolate the issue upstream of the router, identifying sandbox/platform constraints rather than local firewall or NAT misconfiguration.
