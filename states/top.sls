{{ saltenv }}:
  '*':
    - common
    - salt
    - ssh
    - user
  'bastion__core__us-east-2':
    - salt.proxy
  'pmwiki__*__*':
    - apache2
    - lencrypt
    - mount
    #- pmwiki
