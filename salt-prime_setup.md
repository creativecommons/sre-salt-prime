# salt-prime Setup


## /srv Prep

1. Verify `/dev/nvme1n1` is mounted on `/srv`
2. `sudo chgrp sudo /srv`
3. `sudo chmod 2770 /srv`


## Install Blackbox

1. `cd /srv`
2. `git clone https://github.com/StackExchange/blackbox.git`
3. `sudo find blackbox -type d -exec chmod 2775 {} +`
4. `sudo find blackbox -type f -exec chmod g+w {} +`
5. `cd blackbox`
6. `git checkout v1.20180618`
7. `sudo make symlinks-install`


## Checkout sre-salt-prime

1. `cd /srv`
2. `git clone git@github.com:creativecommons/sre-salt-prime.git`
3. `sudo find sre-salt-prime -type d -exec chmod 2775 {} +`
4. `sudo find sre-salt-prime -type f -exec chmod g+w {} +`

