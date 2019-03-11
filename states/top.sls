{{ saltenv }}:
  '*':
    - common
    - postfix
    - salt
    - ssh
    - sudo
    - swapfile
    - user
    - vim
  'bastion__core__us-east-2':
    - salt.proxy
    - user.webdevs
  'chapters__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'discourse__*__*':
    - mount
    - discourse
  'podcast__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
#  'pmwiki__*__*':
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
