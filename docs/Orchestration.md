# Orchestration


## Execution Examples


### Orchestration Run

The following command does a test orchestration run of
[`states/orch/web_host.sls`](../states/orch/web_host.sls):
```shell
sudo salt-run state.orchestrate orch.web_host \
    pillar='{"tgt_hst":"wikijs", "tgt_pod":"core", "tgt_loc":"us-east-2"}' \
    saltenv=timidrobot test=True
```
- `pillar=` is required
  - Infrastructure creation is targeted with CLI pillar
    (`pillar='{"tgt_hst":"wikijs", "tgt_pod":"core", "tgt_loc":"us-east-2"}'`)
- `saltenv=` is optional
  - The command above uses Pillars and States from a development environment
    (`saltenv=timidrobot`). Remove or change to `base` to use production
    environment.
- `test=` is optional
  - The command above performs a dry run (`test=True`). Remove or changed to
    `False` to apply changes.


### Troubleshooting with Salt-Call


#### Local Render

The following command shows how the SLS is rendered and outputs it as YAML:
[`states/orch/aws/ec2_instance_web.sls`](../states/orch/aws/ec2_instance_web.sls):
```shell
sudo salt-call --local --out=yaml state.show_sls orch.aws.ec2_instance_web \
    pillar='{"tgt_hst":"wikijs", "tgt_pod":"core", "tgt_loc":"us-east-2"}' \
    saltenv=timidrobot
```


#### Local Apply

The following command does a local test apply of
[`states/orch/aws/ec2_instance_web.sls`](../states/orch/aws/ec2_instance_web.sls):
```shell
sudo salt-call --local --log-level=debug --log-file-level=warning \
    state.apply orch.aws.ec2_instance_web \
    pillar='{"tgt_hst":"wikijs", "tgt_pod":"core", "tgt_loc":"us-east-2"}' \
    saltenv=timidrobot test=True
```
- Using `salt-call` to run individual states can aid in the troubleshooting of
  orchestration. The `salt-call` command above is very verbose and allows
  errors to be seen in the compiled pillar and state files.


## References


### AWS

- [AWS Resource Types Reference][awstypes]


[awstypes]:http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html


#### Region Selection

- [Save yourself a lot of pain (and money) by choosing your AWS Region wisely -
  Concurrency Labs][awsregion]


[awsregion]:https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/


#### WordPress on AWS

- See [`WordPress.md`](WordPress.md)


### Cloud-Init

- [Cloud config examples — Cloud-Init 18.4 documentation][cloudinit]


[cloudinit]:https://cloudinit.readthedocs.io/en/latest/topics/examples.html


### Debian

- [Cloud/AmazonEC2Image/Stretch - Debian Wiki][debianaws]


[debianaws]:https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch


### SaltStack

See [`../README.md`](../README.md) for information on SaltStack versions and
Best Practices.


#### Module Documentation

AWS orchestration (including bootstrap) makes use of the boto/boto3 state
modules:
- [Salt Module Reference][moduleref]
  - [state modules][statemodules]


[moduleref]: https://docs.saltstack.com/en/latest/ref/index.html
[statemodules]: https://docs.saltstack.com/en/latest/ref/states/all/index.html


#### Orchestration Documentation

- [Orchestrate Runner][orchrunner]


[orchrunner]: https://docs.saltstack.com/en/latest/topics/orchestrate/orchestrate_runner.html


#### Orchestration Examples

- [An example of a complex, multi-host Salt Orchestrate state that performs
  status checks as it goes][statechecks] (2017-08-11)
- [Dynamic Test Servers with Salt | Lincoln Loop][lincoln]a (2017-09-12)
- [SaltStack as an Alternative to Terraform for AWS Orchestration][terraform]
  (2017-08-30, Salt 2017.7.1 was stable version)
- [Running Salt States Using Amazon EC2 Systems Manager | AWS Management Tools
  Blog][sysmgr] (2017-07-16, Salt 2016.11.5 was stable version)
- ~~[Using Salt to boss your clouds around – Anthony Shaw – Medium][boss]
  (2017-05-02, Salt 2016.11.4 was stable version)~~
  - Uses salt-cloud, which has far fewer features than the state boto modules
- ~~[How to Build AWS VPCs with SaltStack Formulas — Six Feet Up][sixfeet]
  (2017-09-19, Salt 2017.7.1 was stable version)~~
  - Uses saltstack-formulas/aws-formula, which only adds a layer above a few
    salt boto state modules.


[lincoln]:https://lincolnloop.com/blog/dynamic-test-servers-salt/
[statechecks]:https://gist.github.com/whiteinge/1bf3b1fa525c2e883b805f271ec6f7d7
[terraform]:https://eng.lyft.com/saltstack-as-an-alternative-to-terraform-for-aws-orchestration-cd2ceb06bf8c
[sysmgr]:https://aws.amazon.com/blogs/mt/running-salt-states-using-amazon-ec2-systems-manager/
[boss]:https://medium.com/@anthonypjshaw/using-salt-to-boss-your-clouds-around-de2edb2f793d
[sixfeet]:https://sixfeetup.com/blog/build-aws-vpc-with-saltstack


#### Boto State Module Examples

- [pedrohdz.com/vpc-bootstrap.sls at master · pedrohdz/pedrohdz.com][pedrohdz]
- [confidant/confidant.sls at master · lyft/confidant][confidant]


[pedrohdz]:https://github.com/pedrohdz/pedrohdz.com/blob/master/content/posts/DevOps/2016-10-14_managing-aws-vpc-saltstack/vpc-bootstrap.sls
[confidant]:https://github.com/lyft/confidant/blob/master/salt/orchestration/confidant.sls


## Repository Documentation

- [`README.md`](../README.md)
- [`bootstrap-aws/README.md`](../bootstrap-aws/README.md)
- `docs/`
  - [`Host_Classification.md`](Host_Classification.md)
  - [`Orchestration.md`](Orchestration.md)
  - [`WordPress.md`](WordPress.md)
