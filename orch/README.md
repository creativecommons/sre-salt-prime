# Orchestration


# Example execuation

The following command does a test orchestration run of
[`pod_pmwiki.sls`](pod_pmwiki.sls):
```shell
sudo salt-run state.orchestrate pod_pmwiki \
    pillar='{"tgt_pod":"core", "tgt_reg":"us-east-2"}' saltenv=timidrobot \
    test=True
```
- `pillar=` is required. Infrastructure creation is targeted with CLI pillar
  (`pillar='{"tgt_pod":"core", "tgt_reg":"us-east-2"}'`)
- `saltenv=` is optional. The command above uses Pillars and States from a 
  development environment (`saltenv=timidrobot`). Remove or change to `base`
  to use production environment.
- `test=` is optional. The cmmand above performs a dry run (`test=True`).
  Remove or changed to `False` to apply changes.


# Example troubleshooting

The following command does a local test run of
[`aws/instance_pmwiki`](aws/instance_pmwiki.sls):
```shell
sudo salt-call --log-level=debug --log-file-level=warning --local state.apply \
    aws.instance_pmwiki pillar='{"tgt_pod":"core", "tgt_reg":"us-east-2"}' \
    saltenv=timidrobot test=True
```
- Using `salt-call` to run individual states can aid troubleshooting of
  orchestration. The `salt-call` command above is very verbose and allows
  errors to be seen in the compiled pillar and state files.


## References


### Orchestration Documentation

- Orchestrate Runner ([latest][orchlatest], [2016.11][orch2016])
  - Examples:
    - [An example of a complex, multi-host Salt Orchestrate state that performs status checks as it goes](https://gist.github.com/whiteinge/1bf3b1fa525c2e883b805f271ec6f7d7)
    - [Dynamic Test Servers with Salt | Lincoln Loop](https://lincolnloop.com/blog/dynamic-test-servers-salt/)


[orchlatest]: https://docs.saltstack.com/en/latest/topics/orchestrate/orchestrate_runner.html
[orch2016]: https://docs.saltstack.com/en/2016.11/topics/orchestrate/orchestrate_runner.html


## Related

- [`../README.md`](..README.md)
