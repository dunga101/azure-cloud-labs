# Architecture Diagram

## Mermaid Diagram

```mermaid
flowchart TD
    Internet((Internet))
    PublicIP[Azure Public IP\npip-router\n20.124.227.236]

    subgraph Azure["Microsoft Azure"]
        subgraph VNet["vnet-smarttrade\n10.10.0.0/16"]
            subgraph DMZ["dmz-subnet\n10.10.1.0/24"]
                Router["vm-router\nUbuntu 22.04\nPrivate IP: 10.10.1.4\nIP Forwarding: Enabled\niptables NAT: Enabled"]
            end

            subgraph Internal["internal-subnet\n10.10.2.0/24"]
                Client["vm-client\nUbuntu 22.04\nPrivate IP: 10.10.2.5\nNo Public IP"]
            end

            RouteTable["rt-internal\n0.0.0.0/0 → Virtual Appliance\nNext hop: 10.10.1.4"]
            NSG["nsg-router\nAllow SSH 22\nAllow OpenVPN UDP 1194\nAllow IKE UDP 500\nAllow NAT-T UDP 4500"]
        end
    end

    Internet --> PublicIP --> Router
    NSG -. protects .-> Router
    RouteTable -. associated to .-> Internal
    Client -. intended default route via UDR .-> Router
```

## Design Notes

This lab models an Azure NVA pattern using a Linux VM as a software router. The router VM is placed in a DMZ subnet and exposed through a controlled public IP and NSG rules. The internal client VM has no public IP and resides in a separate internal subnet.

The internal subnet was associated with a route table that forwards default traffic to the router VM as a virtual appliance next hop.
