# sre-salt-prime

Site Reliability Engineering / DevOps SaltStack configuration files


## Code of Conduct

[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md):
> The Creative Commons team is committed to fostering a welcoming community.
> This project and all other Creative Commons open source projects are governed
> by our [Code of Conduct][code_of_conduct]. Please report unacceptable
> behavior to [conduct@creativecommons.org](mailto:conduct@creativecommons.org)
> per our [reporting guidelines][reporting_guide].

[code_of_conduct]:https://creativecommons.github.io/community/code-of-conduct/
[reporting_guide]:https://creativecommons.github.io/community/code-of-conduct/enforcement/


## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).


## Development Notes

- **Avoid insecure repository clones:** This repository includes encrypted
  secrets. Do not run `git-crypt unlock` on clones that are not otherwise
  secured (ex. strong login password, disk encryption).
- **Avoid editing the base environment:** The base environment is configured to
  prevent commit and push actions. Please use your development environment and
  pull the changes to base.
- **Sign your commits:**
  - The master branch has the Require signed commits (Include administrators)
    GitHub branch protection enabled.
    - [About required commit signing - User Documentation][signing]
  - Ensure you are using `RemoteForward` in your SSH configuration to forward
    your GnuPG agent to `salt-prime` (see the example configuration, under
    [Setup](#Setup), below).
  - Ensure you have configured your newly cloned repository to sign commits
    (see the `git config` command, under [Setup](#Setup), below).

[signing]:https://help.github.com/articles/about-required-commit-signing/


### Setup

- **SSH connection information:** example local/laptop `~/.ssh/config`
  configugration:
    ```
    Host bastion-us-east-2
        HostName bastion-us-east-2.creativecommons.org
        User ARTHUR

    Host salt-prime
        HostName 10.22.11.11
        ProxyJump bastion-us-east-2
        RemoteForward /run/user/4242/gnupg/S.gpg-agent /Users/ARTHUR/.gnupg/S.gpg-agent.extra
        User ARTHUR

    Host *
        ServerAliveCountMax 60
        ServerAliveInterval 30
        TCPKeepAlive no
    ```
    - Assumes remote username ARTHUR and remote uid 4242. Replace these values
      in your own local/laptop configuration.
    - ProxyJump allows you to `ssh salt-prime` from your local/laptop.
    - RemoteForward allows you to sign your commits.
- **Setup your development repository** on `salt-prime`:
  1. Clone repository to `/srv` with your username. For example:
        ```shell
        cd /srv
        git clone git@github.com:creativecommons/sre-salt-prime.git ${USER}
        ```
  2. Setup your newly cloned repository.
     1. Configure commit signing:
        ```shell
        cd /srv/${USER}
        git config user.email YOUR_EMAIL
        git config user.signingkey YOUR_GPG_ID
        git config commit.gpgsign true
        ```
     1. Unlock encrypted secrets:
        ```shell
        cd /srv/${USER}
        git-crypt unlock
        ```
  3. Specify the environment when you test changes. For example:
        ```shell
        sudo salt \* state.highstate saltenv=${USER} test=True
        ```
     - use `--state-verbose=True` to see successes
     - use `--state-output=full_id` to see full detail of successes
     - use `--log-level=debug --log-file-level=warning` to see debug messages
       (without logging those debug messages, which may contain secrets, to the
       log file)


### Goals

- Use AWS well, but avoid technologies that are create AWS lock-in (ex.
  Confidant)
- Salt Prime must not contain any exclusive data (use Git)
- Git repository must not contain any unencrypted secrets
- Git repository commits must be signed
- A compromised minion must not be able to escalate access
  - SysAdmins must not forward their SSH agent
  - Must not reuse application passwords (ex. Prod and Dev databases must have
    different passwords)
  - Pillar data must be restricted by Minion ID based classification
    - *The only grain which can be safely used is `grains['id']` which contains
      the Minion ID.* ([FAQ Q.21][FAQ21])

[FAQ21]: https://docs.saltstack.com/en/latest/faq.html#is-targeting-using-grain-data-secure


### Decisions

- Amazon Web Services (AWS)
  - Creative Commons is already using it and staff are familiar with it
  - Features allow security (ex. screened subnets, security groups policies)
  - Features allows Infrastructure as Code
  - `us-east-2`
    - cost effective
    - avoid conflict/collision over region limited resources (ex. ElasticIPs)
- Debian 10 (Buster) and Debian 9 (Stretch)
  - Free/Open Source
  - Debian Stable
  - Creative Commons is already using it and staff are familiar with it
- [git-crypt][gitcrypt] - transparent file encryption in git
  - Free/Open Source
  - Performance: files are decrypted in the checked out repository
  - Security: automatic encryption and directory based filters minimize the
    chance of unencrypted secrets being pushed to GitHub
- SaltStack
  - Free/Open Source
  - Performance
  - Creative Commons is already using it and staff are familiar with it
  - Version: `2019.2.2`
    - For current targeted minion version, see `minion_target_version` in
     [`pillars/salt/init.sls`](pillars/salt/init.sls)

[gitcrypt]: https://www.agwa.name/projects/git-crypt/


## Host Classification

Minions are added and configured from `salt-prime` with the following Minion ID
schema: **`HST__POD__LOC`** (host/role__pod/group__location).

See [`docs/Host_Classification.md`](docs/Host_Classification.md) for details.


## Orchestration

See [`docs/Orchestration.md`](docs/Orchestration.md).


## References


### SaltStack

- For the SaltStack version that this repository is developed on, see
  [Decisions](#Decisions), above.
- This repository attempts to tracks the most current release of SaltStack in
  the SaltStack Debian repository: https://repo.saltstack.com/apt/debian/
- For current version of SaltStack in Debian proper, see [Debian -- Package
  Search Results -- salt-master][pkgsearch]

[pkgsearch]: https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=salt-master


####  Best Practices

- [Hardening Salt][hardensalt]
  - *The only grain which can be safely used is `grains['id']` which contains
    the Minion ID.* ([FAQ Q.21][FAQ21])
- [Salt Best Practices][saltbest]
- [Salt Formulas][saltformulas]

[hardensalt]: https://docs.saltstack.com/en/latest/topics/hardening.html
[saltbest]: https://docs.saltstack.com/en/latest/topics/best_practices.html
[saltformulas]: https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html


#### Module Documentation

- [Salt Module Reference][moduleref]
  - [state modules][statemodules]

[moduleref]: https://docs.saltstack.com/en/latest/ref/index.html
[statemodules]: https://docs.saltstack.com/en/latest/ref/states/all/index.html


## Repository Documentation

- [`README.md`](README.md)
- [`bootstrap-aws/README.md`](bootstrap-aws/README.md)
- `docs/`
  - [`Host_Classification.md`](docs/Host_Classification.md)
  - [`Orchestration.md`](docs/Orchestration.md)
  - [`WordPress.md`](docs/WordPress.md)


## Formula Repositories

- [creativecommons/mysql-formula][mysql-formula]: Install the MySQL client
  and/or server
- [creativecommons/php-formula][php-formula]: Formula to set up and configure
  php

[certbot]:https://github.com/certbot/certbot
[mysql-formula]:https://github.com/creativecommons/mysql-formula
[php-formula]:https://github.com/creativecommons/php-formula


## License

- [`LICENSE`](LICENSE) (Expat/[MIT][mit] License)

[mit]: http://www.opensource.org/licenses/MIT "The MIT License | Open Source Initiative"
