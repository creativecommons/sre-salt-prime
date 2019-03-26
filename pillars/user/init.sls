include:
  - user.secrets


user:
  admin_groups:
    # composer per states/php_cc/composer.sls
    # www-data per states/apache2/init.sls
    - adm
    - audio
    - cdrom
    - dialout
    - dip
    - floppy
    - netdev
    - plugdev
    - sudo
    - video
  webdev_groups:
    # composer per states/php_cc/composer.sls
    # www-data per states/apache2/init.sls
    - adm
{#
 # Admins are stored in user.secrets to reduce mail harvesting. The expected
 # data structure is demonstrated below:
 #
 #  admins:
 #    arthur:
 #      id: 4242
 #      fullname: Arthur Dent
 #      mail: arthurdent@creativecommons.org
 #      shell: /bin/bash
 #      sshpub:
 #        ed25519:
 #          - arthur_ed25519_production_20190102.pub
 #        rsa:
 #          - arthur_rsa_legacy_20190102.pub
 #          - arthur_rsa_inherited_20190102.pub
 #
 # WebDevs follow the same structure but under webdevs insteead of admins.
 #}
