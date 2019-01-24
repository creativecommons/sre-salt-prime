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
  'chapters__*__*':
    - apache2
    - lencrypt
    - mount
    - mysql_cc.root_my_cnf
    - php.ng.apache2
    - php.ng.cli
    - php.ng.composer
    - php.ng.mysqlnd
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
