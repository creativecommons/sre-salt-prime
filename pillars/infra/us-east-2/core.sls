infra:
  us-east-2:
    core:
      host_ips:
{#- sort host_ips with the following external vim command:
!sort -n -t . -k 2,2 -k 3,3 -k 4,4 -k 5,5
#}
        # DMZ         10.22.10.0
        bastion:      10.22.10.10
        pmwiki:       10.22.10.11
        wikijs:       10.22.10.12
        # Private-One 10.22.11.0
        salt-prime:   10.22.11.11
        chapters:     10.22.11.12
        # Private-Two 10.22.12.0
      subnets:
        dmz:
          cidr: 10.22.10.0/24
          az: us-east-2a
          route_table: internet_core_route-table
          tag_routing: Internet Gateway
        private-one:
          cidr: 10.22.11.0/24
          az: us-east-2b
          route_table: nat_core_route-table
          tag_routing: NAT Gateway
        private-two:
          cidr: 10.22.12.0/24
          az: us-east-2c
          route_table: nat_core_route-table
          tag_routing: NAT Gateway
      web_secgroups:
        default:
          - pingtrace-all_core_secgroup
          - ssh-from-salt-prime_core_secgroup
          - ssh-from-bastion_core_secgroup
          - web-all_core_secgroup
        chapters:
          - pingtrace-all_core_secgroup
          - ssh-from-salt-prime_core_secgroup
          - ssh-from-bastion_core_secgroup
          - web-all-chapters_core_secgroup

