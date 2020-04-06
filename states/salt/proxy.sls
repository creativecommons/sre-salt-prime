# NOTE: It may be better to manage iptables per:
#         Managing IPtables efficiently with Saltstack - Server Fault
#         https://serverfault.com/a/948526


# Configure proxy host (it should have a static public IP) to forward SaltStack
# traffic to salt prime host
{% set PROXY_IP = pillar.location.salt_proxy_ip -%}
{% set SALT_IP = pillar.location.salt_prime_ip -%}


# Persist iptables rules through reboot - Issue #30667 - saltstack/salt
# https://github.com/saltstack/salt/issues/30667
{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - conntrack
      - iptables-persistent


{{ sls }} enable ipv4 forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} append filter forward established:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - protocol: tcp
    - match: conntrack
    - ctstate: ESTABLISHED,RELATED
    - jump: ACCEPT
    - save: True
    - require:
      - pkg: {{ sls }} installed packages
      - sysctl: {{ sls }} enable ipv4 forward


{% for port in [4505, 4506] -%}
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
    - require:
      - pkg: {{ sls }} installed packages
      - sysctl: {{ sls }} enable ipv4 forward


{{ sls }} append nat prerouting {{ port }}:
  iptables.append:
    - table: nat
    - chain: PREROUTING
    - protocol: tcp
    - dport: {{ port }}
    - to-destination: {{ SALT_IP }}:{{ port }}
    - jump: DNAT
    - save: True
    - require:
      - pkg: {{ sls }} installed packages
      - sysctl: {{ sls }} enable ipv4 forward


{{ sls }} append nat postrouting {{ port }}:
  iptables.append:
    - table: nat
    - chain: POSTROUTING
    - protocol: tcp
    - dport: {{ port }}
    - destination: {{ SALT_IP }}
    - to-source: {{ PROXY_IP }}
    - jump: SNAT
    - save: True
    - require:
      - pkg: {{ sls }} installed packages
      - sysctl: {{ sls }} enable ipv4 forward
{% endfor -%}
