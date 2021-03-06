# Host Classification


## Overview

Minions are added and configured from `salt-prime` with the following Minion ID
schema: **`HST__POD__LOC`**:
1. **`HST`** is the hostname or role. It indications what services are running on
   the host or the role that it serves.
2. **`POD`** is the pod or group. It indicates the logical grouping of the host.
3. **`LOC`** is the location. It indicates where the host is.

Examples:
- `bastion__core__us-east-2`
- `salt-prime__core__us-east-2`
- `chapters__prod__us-east-2`
- `chapters__stage__us-east-2`

This host classification allows multiple levels of specificity to minimize the
configuration required between similar hosts.

Like Apache2, SaltStack pillar data uses a last declared wins model. This
repository uses (from least-specific to most-specific):

1. `1_LOC` (location)
2. `2_POD` (pod/group)
3. `3_HST` (host/role)
4. `4_POD__LOC` (pod/group and location)
5. `5_HST__POD` (host/role and pod/group)

This method of setting least-specific to most-specific pillar data was inspired
by Puppet Hiera.


## Implementation

The `HST__POD__LOC` schema is implemented using Jinja2 in the
[`pillars/top.sls`](../pillars/top.sls) file.

Implementation is also supported by three configuration values:
- Master
  - `pillarenv_from_saltenv: True` (see [Configuring the Salt
    Master][master-from-env])
- Minion
  - `pillarenv_from_saltenv: True` (see [Configuring the Salt
    Minion][minion-from-env])
  - `top_file_merging_strategy: same` (see [Configuring the Salt
    Minion][merging-strategy])

[master-from-env]: https://docs.saltstack.com/en/latest/ref/configuration/master.html#pillarenv-from-saltenv
[minion-from-env]: https://docs.saltstack.com/en/latest/ref/configuration/minion.html#pillarenv-from-saltenv
[merging-strategy]: https://docs.saltstack.com/en/latest/ref/configuration/minion.html#std:conf_minion-top_file_merging_strategy


## Security

*The only grain which can be safely used is `grains['id']` which contains the
Minion ID.* ([FAQ Q.21][FAQ21])

It is important to rely *only* on the Minion ID as all other grains can be
manipulated by the client. This means a compromised client could change its
grains to collect secrets if a dedicated grain (ex. `role`) was used for host
classification.

[FAQ21]: https://docs.saltstack.com/en/latest/faq.html#is-targeting-using-grain-data-secure


## Orchestration

See [`Orchestration.md`](Orchestration.md) for how these classification parts
are used with orchestration.


## Node Groups

[Node groups][nodegroups] provide similar functionality. However they are far
less flexible and have a number of issues:
- They are configured at server run time (`salt-master` must be restarted to
  apply changes)
- They do not allow a least-specific to most-specific configuration path
- [open "nodegroup" Issues · saltstack/salt][nodegroup-issues]

[nodegroups]: https://docs.saltstack.com/en/latest/topics/targeting/nodegroups.html
[nodegroup-issues]: https://github.com/saltstack/salt/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+nodegroups


## References


## Repository Documentation

- [`README.md`](../README.md)
- [`bootstrap-aws/README.md`](../bootstrap-aws/README.md)
- `docs/`
  - [`Host_Classification.md`](Host_Classification.md)
  - [`Orchestration.md`](Orchestration.md)
  - [`WordPress.md`](WordPress.md)
