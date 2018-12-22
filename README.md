# sre-salt-prime

Site Reliability Engineering / DevOps SaltStack configuration files - NEW!

(This will eventually completely replace `sre-salt`.)


## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct
([`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)). By participating in this
project you agree to abide by its terms.


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
    your GnuPG agent to `salt-prime` (see the example configurationi, under
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
- Debian 9 (Stretch)
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
  - Version: `2018.3`
    - For current targeted minion version, see `minion_target_version` in
     [`pillars/salt/init.sls`](pillars/salt/init.sls)


[gitcrypt]: https://www.agwa.name/projects/git-crypt/


## Host Classification

Minions are added and configured from `salt-prime` with the following Minion ID
schema: **`name__pod__location`**. Examples:
- `bastion__core__us-east-2`
- `salt-prime__core__us-east-2`

Glob patterns are used in [`pillars/top.sls`](pillars/top.sls) to ensure pillar
data is scoped appropriately (as narrowly as possible).



## Orchestration

See [`orch/README.md`](orch/README.md).


## References


### AWS

- [AWS Resource Types Reference](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)


#### Region Selection

- [Save yourself a lot of pain (and money) by choosing your AWS Region wisely - Concurrency Labs](https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/)


#### WordPress on AWS

- [Build a WordPress Website - AWS](https://aws.amazon.com/getting-started/projects/build-wordpress-website/) (version: last modified 2018-10-19)
  - [WordPress: Best Practices on AWS](https://d0.awsstatic.com/whitepapers/wordpress-best-practices-on-aws.pdf) (PDF, 2018-02-12)


### Cloud-Init

- [Cloud config examples — Cloud-Init 18.4 documentation](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)


### Debian

- [Cloud/AmazonEC2Image/Stretch - Debian Wiki](https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch)


### SaltStack

As of 2018-12-22, Debian Stretch's SaltStack packages are at version 2016.11.2.
- For the SaltStack version that this repository is developed on, see
  [Decisions](#Decisions), above.
- For current version of SaltStack in Debian Stretch, see
  [Debian -- Package Search Results -- salt-master][pkgsearch]


[pkgsearch]:https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=salt-master


####  Best Practices

- Hardening Salt (**[latest][hardenlatest]**, [2016.11][harden2016])
  - *The only grain which can be safely used is `grains['id']` which contains
    the Minion ID.* ([FAQ Q.21][FAQ21])
- Salt Best Practices (**[latest][bestlatest]**, [2016.11][best2016])
- Salt Formulas (**[latest][formulaslatest]**, [2016.11][formulas2016])


[hardenlatest]: https://docs.saltstack.com/en/latest/topics/hardening.html
[harden2016]: https://docs.saltstack.com/en/2016.11/topics/hardening.html
[bestlatest]: https://docs.saltstack.com/en/latest/topics/best_practices.html
[best2016]: https://docs.saltstack.com/en/2016.11/topics/best_practices.html
[formulaslatest]: https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html
[formulas2016]: https://docs.saltstack.com/en/2016.11/topics/development/conventions/formulas.html


#### Module Documentation

- Salt Module Reference (**[latest][modulelatest]**, [2016.11][module2016])
  - state modules (**[latest][statelatest]**, [2016.11][state2016])


[modulelatest]: https://docs.saltstack.com/en/latest/ref/index.html
[module2016]: https://docs.saltstack.com/en/2016.11/ref/index.html
[statelatest]: https://docs.saltstack.com/en/latest/ref/states/all/index.html
[state2016]: https://docs.saltstack.com/en/2016.11/ref/states/all/index.html


#### Orchestration Documentation

See [`orch/README.md`](orch/README.md).


## Bootstrap

See [`bootstrap-aws/README.md`](bootstrap-aws/README.md).


## License

- [`LICENSE`](LICENSE) (Expat/[MIT][mit] License)


[mit]: http://www.opensource.org/licenses/MIT "The MIT License | Open Source Initiative"
