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
  'biztool__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'chapters__*__*':
    - letsencrypt.cloudflare
    - mount
    - user.webdevs
    - wordpress.composer_site
  'discourse__*__*':
    - mount
    - discourse
  'openglam__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'podcast__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'redirects__*__*':
    - nginx.redirects
  'salt-prime__*__*':
    - wikijs.reports
  'sotc__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'summit__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'wikijs__*__*':
    - letsencrypt
    - mongodb
    - mount
    - nginx.wikijs
    - nodejs
    - wikijs
