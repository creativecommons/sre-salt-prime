infra:
  us-east-2:
    core:
      host_ips:
{#- sort host_ips with the following external vim command:
!sort -n -t . -k 2,2 -k 3,3 -k 4,4 -k 5,5
#}
        ###_DMZ                 10.22.10.0
        bastion__core:          10.22.10.10
        wikijs__core:           10.22.10.12
        #_NAT_Gateway:          10.22.10.13
        chapters__prod:         10.22.10.14
        podcast__prod:          10.22.10.15
        discourse__dev:         10.22.10.16
        biztool__prod:          10.22.10.17
        chapters__stage:        10.22.10.18
        redirects__core:        10.22.10.19
        sotc__prod:             10.22.10.20
        openglam__prod:         10.22.10.21
        summit__prod:           10.22.10.22
        dispatch__stage:        10.22.10.23
        licbuttons__prod:       10.22.10.24
        dispatch__prod:         10.22.10.25
        cclicdev__stage:        10.22.10.26
        opencovid__prod:        10.22.10.27
        dispatch__stagelegacy:  10.22.10.28
        cert__prod:             10.22.10.29
        ###_Private-One         10.22.11.0
        salt-prime__core:       10.22.11.11
        ccengine__stage:        10.22.11.12
        ccengine__prod:         10.22.11.13
        misc__stage:            10.22.11.14
        misc__prod:             10.22.11.15
        ccorgwp__stage:         10.22.11.16
        ccorgwp__stagelegacy:   10.22.11.17
        licenses__stage:        10.22.11.18
        ###_Private-Two         10.22.12.0
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
