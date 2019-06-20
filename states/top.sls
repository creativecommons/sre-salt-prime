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
  'podcast__*__*':
    - mount
    - wordpress.composer_site
    - user.webdevs
  'redirects__*__*':
    - nginx.redirects
  'sotc__*__*':
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
