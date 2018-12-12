{{ saltenv }}:
  '*':
    - common
    - salt
    - ssh
    - user
  bastion__core__us-east-2:
    - match: glob
    - salt.proxy
