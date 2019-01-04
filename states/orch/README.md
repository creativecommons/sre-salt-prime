# Orchestration


## Execution Examples


### Orchestration Run

The following command does a test orchestration run of
[`pmwiki.sls`](pmwiki.sls):
```shell
sudo salt-run state.orchestrate orch.pmwiki \
    pillar='{"tgt_pod":"core", "tgt_loc":"us-east-2"}' saltenv=timidrobot \
    test=True
```
- `pillar=` is required
  - Infrastructure creation is targeted with CLI pillar
    (`pillar='{"tgt_pod":"core", "tgt_loc":"us-east-2"}'`)
- `saltenv=` is optional
  - The command above uses Pillars and States from a development environment
    (`saltenv=timidrobot`). Remove or change to `base` to use production
    environment.
- `test=` is optional
  - The command above performs a dry run (`test=True`). Remove or changed to
    `False` to apply changes.


### Troubleshooting with Salt-Call

The following command does a local test run of
[`aws/instance_pmwiki`](aws/instance_pmwiki.sls):
```shell
sudo salt-call --log-level=debug --log-file-level=warning --local state.apply \
    orch.aws.instance_pmwiki \
    pillar='{"tgt_pod":"core", "tgt_loc":"us-east-2"}' \
    saltenv=timidrobot test=True
```
- Using `salt-call` to run individual states can aid in the troubleshooting of
  orchestration. The `salt-call` command above is very verbose and allows
  errors to be seen in the compiled pillar and state files.


## References

See [`../README.md`](..README.md) for information on SaltStack versions.


### Orchestration Documentation

- Orchestrate Runner (**[latest][orchlatest]**, [2016.11][orch2016])


[orchlatest]: https://docs.saltstack.com/en/latest/topics/orchestrate/orchestrate_runner.html
[orch2016]: https://docs.saltstack.com/en/2016.11/topics/orchestrate/orchestrate_runner.html


### Orchestration Examples

- [An example of a complex, multi-host Salt Orchestrate state that performs status checks as it goes][statechecks] (2017-08-11)
- [Dynamic Test Servers with Salt | Lincoln Loop][lincoln]a (2017-09-12)
- [SaltStack as an Alternative to Terraform for AWS Orchestration][terraform]
  (2017-08-30, Salt 2017.7.1 was stable version)
- [Running Salt States Using Amazon EC2 Systems Manager | AWS Management Tools Blog][sysmgr] (2017-07-16, Salt 2016.11.5 was stable version)
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


### Module Documentation

AWS orchestration (including bootstrap) makes use of the boto/boto3 state
modules:
- Salt Module Reference (**[latest][modulelatest]**, [2016.11][module2016])
  - state modules (**[latest][statelatest]**, [2016.11][state2016])


[modulelatest]: https://docs.saltstack.com/en/latest/ref/index.html
[module2016]: https://docs.saltstack.com/en/2016.11/ref/index.html
[statelatest]: https://docs.saltstack.com/en/latest/ref/states/all/index.html
[state2016]: https://docs.saltstack.com/en/2016.11/ref/states/all/index.html


#### Boto State Module Examples

- [pedrohdz.com/vpc-bootstrap.sls at master · pedrohdz/pedrohdz.com][pedrohdz]
- [confidant/confidant.sls at master · lyft/confidant][confidant]


[pedrohdz]:https://github.com/pedrohdz/pedrohdz.com/blob/master/content/posts/DevOps/2016-10-14_managing-aws-vpc-saltstack/vpc-bootstrap.sls
[confidant]:https://github.com/lyft/confidant/blob/master/salt/orchestration/confidant.sls


### Creative Commons Terraform

Creative Commons is exploring both SaltStack and Terraform for
provisioning/orchestration. Also see:
- [cccatalog-api/deployment at master · creativecommons/cccatalog-api](https://github.com/creativecommons/cccatalog-api/tree/master/deployment)


## Related

- [`../README.md`](..README.md)
