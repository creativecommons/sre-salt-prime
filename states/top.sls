base:
  '*':
    - common
    - ssh
    - user
  'virtual:kvm':
    - match: grain
    - common.virtual
  'roles:salt-prime':
    - match: pillar_exact
    - salt.prime
  bastion__core__us-east-2:
    - match: glob
    - salt.proxy
