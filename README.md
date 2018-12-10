## Goals

- Use AWS well, but avoid technologies that are create AWS lock-in (ex.
  Confidant)
- Salt Prime must not contain any exclusive data (use Git)
- Git repository must not contain any unencrypted secrets
- A compromised minion must not be able to escalate access
  - SysAdmins must not forward their SSH agent
  - Must not reuse application passwords (ex. Prod and Dev databases must have
    different passwords)
  - *The only grain which can be safely used is `grains['id']` which contains the Minion ID.* ([FAQ Q.21][FAQ21])


[FAQ21]: https://docs.saltstack.com/en/latest/faq.html#is-targeting-using-grain-data-secure


## Decisions

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


[gitcrypt]: https://www.agwa.name/projects/git-crypt/


## Bootstrap

See [`bootstrap-aws/README.md`](bootstrap-aws/README.md).


## References


### AWS

- [AWS Resource Types Reference](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)


#### Region Selection

- [Save yourself a lot of pain (and money) by choosing your AWS Region wisely - Concurrency Labs](https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/)


#### SaltStack on AWS

- [How to Build AWS VPCs with SaltStack Formulas — Six Feet Up](https://sixfeetup.com/blog/build-aws-vpc-with-saltstack) (2017-09-19, Salt 2017.7.1 was stable version)
- [SaltStack as an Alternative to Terraform for AWS Orchestration](https://eng.lyft.com/saltstack-as-an-alternative-to-terraform-for-aws-orchestration-cd2ceb06bf8c) (2017-08-30, Salt 2017.7.1 was stable version)
- [Running Salt States Using Amazon EC2 Systems Manager | AWS Management Tools Blog](https://aws.amazon.com/blogs/mt/running-salt-states-using-amazon-ec2-systems-manager/) (2017-07-16, Salt 2016.11.5 was stable version)
- [Using Salt to boss your clouds around – Anthony Shaw – Medium](https://medium.com/@anthonypjshaw/using-salt-to-boss-your-clouds-around-de2edb2f793d) (2017-05-02, Salt 2016.11.4 was stable version)


#### WordPress on AWS

- [Build a WordPress Website - AWS](https://aws.amazon.com/getting-started/projects/build-wordpress-website/) (version: last modified 2018-10-19)
  - [WordPress: Best Practices on AWS](https://d0.awsstatic.com/whitepapers/wordpress-best-practices-on-aws.pdf) (PDF, 2018-02-12)


### Cloud-Init

- [Cloud config examples — Cloud-Init 18.4 documentation](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)


### Creative Commons Terraform

- [cccatalog-api/deployment at master · creativecommons/cccatalog-api](https://github.com/creativecommons/cccatalog-api/tree/master/deployment)


### Debian

- [Cloud/AmazonEC2Image/Stretch - Debian Wiki](https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch)


### SalStack

As of 2018-12-10, Debian Stretch's SaltStack packages are at version 2016.11.2.


####  Best Practices

- Hardening Salt ([latest][hardenlatest], [2016.11][harden2016])
  - *The only grain which can be safely used is `grains['id']` which contains
    the Minion ID.* ([FAQ Q.21][FAQ21])
- Salt Best Practices ([latest][bestlatest], [2016.11][best2016])
- Salt Formulas ([latest][formulaslatest], [2016.11][formulas2016])

[hardenlatest]: https://docs.saltstack.com/en/latest/topics/hardening.html
[harden2016]: https://docs.saltstack.com/en/2016.11/topics/hardening.html
[bestlatest]: https://docs.saltstack.com/en/latest/topics/best_practices.html
[best2016]: https://docs.saltstack.com/en/2016.11/topics/best_practices.html
[formulaslatest]: https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html
[formulas2016]: https://docs.saltstack.com/en/2016.11/topics/development/conventions/formulas.html


#### Module Documentation

- Salt Module Reference ([latest][modulelatest], [2016.11][module2016])
  - state modules ([latest][statelatest], [2016.11][state2016])
    - For AWS Bootstrap and Orchestration, see boto modules
    - Boto State Examples:
      - [pedrohdz.com/vpc-bootstrap.sls at master · pedrohdz/pedrohdz.com](https://github.com/pedrohdz/pedrohdz.com/blob/master/content/posts/DevOps/2016-10-14_managing-aws-vpc-saltstack/vpc-bootstrap.sls)
      - [confidant/confidant.sls at master · lyft/confidant](https://github.com/lyft/confidant/blob/master/salt/orchestration/confidant.sls)

[modulelatest]: https://docs.saltstack.com/en/latest/ref/index.html
[module2016]: https://docs.saltstack.com/en/2016.11/ref/index.html
[statelatest]: https://docs.saltstack.com/en/latest/ref/states/all/index.html
[state2016]: https://docs.saltstack.com/en/2016.11/ref/states/all/index.html


## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct
([`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)). By participating in this
project you agree to abide by its terms.


## License

- [`LICENSE`](LICENSE) (Expat/[MIT License][MIT])

[MIT]: http://www.opensource.org/licenses/MIT "The MIT License (MIT)"
