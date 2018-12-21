infra:
  aws:
    us-east-2:
      gnwp:
        subnets:
          dmz:
            cidr: 10.22.20.0/24
            az: us-east-2a
            route_table: internet_core_route-table
            tag_routing: Internet Gateway
          private-one:
            cidr: 10.22.21.0/24
            az: us-east-2b
            route_table: nat_core_route-table
            tag_routing: NAT Gateway
          private-two:
            cidr: 10.22.22.0/24
            az: us-east-2c
            route_table: nat_core_route-table
            tag_routing: NAT Gateway
        hosts_ips:
          wordpress: 10.22.21.10
