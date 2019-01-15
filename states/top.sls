{{ saltenv }}:
  '*':
    - common
    - postfix
    - salt
    - ssh
    - sudo
    - user
    - vim
  'bastion__core__us-east-2':
    - salt.proxy
#  'pmwiki__*__*':
#    - apache2
#    - apache2.pmwiki
#    - lencrypt
#    - mount
#    - pmwiki
  'wikijs__*__*':
    - lencrypt
    - mongodb
    - mount
    - nginx.wikijs
    - nodejs
    - wikijs
