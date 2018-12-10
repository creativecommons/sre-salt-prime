# Configure proxy host (it should have a static public IP) to forward SaltStack
# traffic to salt prime host
#
# Public Proxy IP
{% set proxy_ip = '10.22.10.10' -%}
# Salt Prime IP
{% set salt_ip = '10.22.11.11' -%}

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

{{ sls }} append filter forward established:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: tcp
    - match: conntrack
    - ctstate: ESTABLISHED,RELATED
    - jump: ACCEPT
    - save: True

{% for port in [4505, 4506] %}
{{ sls }} append filter forward new {{ port }}:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: tcp
    - match: conntrack
    - ctstate: NEW
    - dport: {{ port }}
    - jump: ACCEPT
    - save: True
{{ sls }} append nat prerouting {{ port }}:
  iptables.append:
    - table: nat
    - chain: PREROUTING
    - protocol: tcp
    - dport: {{ port }}
    - to-destination: {{ salt_ip }}:{{ port }}
    - jump: DNAT
    - save: True
{{ sls }} append nat postrouting {{ port }}:
  iptables.append:
    - table: nat
    - chain: POSTROUTING
    - protocol: tcp
    - dport: {{ port }}
    - destination: {{ salt_ip }}
    - to-source: {{ proxy_ip }}
    - jump: SNAT
    - save: True
{% endfor %}
