# WordPress


## References


### Composer

- [Composer][composer]
- [Composer in WordPress][composerwp]
- [composer/installers][installers]: A Multi-Framework Composer Library
  Installer
- [WordPress Packagist][wpackagist]: Manage your plugins and themes with
  Composer


[composer]:https://getcomposer.org/
[composerwp]:https://composer.rarst.net/
[installers]:https://github.com/composer/installers
[wpackagist]:https://wpackagist.org/


### Saltstack

- See [`../README.md`](../README.md) for information on SaltStack versions and
  Best Practices.


#### Module Documentation

AWS orchestration (including bootstrap) makes use of the boto/boto3 state
modules:
- [Salt Module Reference][moduleref]
  - [state modules][statemodules]
    - [salt.states.composer][statescomposer]


[moduleref]: https://docs.saltstack.com/en/latest/ref/index.html
[statemodules]: https://docs.saltstack.com/en/latest/ref/states/all/index.html
[statescomposer]:https://docs.saltstack.com/en/latest/ref/states/all/salt.states.composer.html


### WordPress

- [Hardening WordPress « WordPress Codex][hardenwp]
  - [php - Correct file permissions for WordPress - Stack Overflow][wpperms]
  - [Administration Over SSL « WordPress Codex][adminssl]
- [Editing wp-config.php « WordPress Codex][wpconfig]
- [Command line interface for WordPress | WP-CLI][wpcli]


[hardenwp]:https://codex.wordpress.org/Hardening_WordPress
[wpperms]:https://stackoverflow.com/a/25865028/568372
[adminssl]:https://codex.wordpress.org/Administration_Over_SSL
[wpconfig]:https://codex.wordpress.org/Editing_wp-config.php
[wpcli]:https://wp-cli.org/


## Formula Repositories

- See [`../README.md#formula-repositories`](../README.md#formula-repositories)


## Repository Documentation

- [`README.md`](../README.md)
- [`bootstrap-aws/README.md`](../bootstrap-aws/README.md).
- `docs/`
  - [`Orchestration.md`](Orchestration.md)
  - [`WordPress.md`](WordPress.md)
