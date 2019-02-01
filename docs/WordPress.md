# WordPress


## References


### Composer

- [Composer][composer]
- [Composer in WordPress][composerwp]
- [WordPress Packagist: Manage your plugins and themes with
  Composer][wpackagist]


[composer]:https://getcomposer.org/
[composerwp]:https://composer.rarst.net/
[wpackagist]:https://wpackagist.org/


### Saltstack

See [`../README.md`](../README.md) for information on SaltStack versions and
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

- [WP-CLI][wpcli] - The command line interface for WordPress


[wpcli]:https://make.wordpress.org/cli/


## Formula Repositories

- [creativecommons/wordpress-formula][wordpress-formula]: Wordpress Salt
  Formula
- For additional formula repositories (ex. php), see
  [`../README.md#formula-repositories`](../README.md#formula-repositories)


[wordpress-formula]:https://github.com/creativecommons/wordpress-formula


## Repository Documentation

- [`README.md`](../README.md)
- [`bootstrap-aws/README.md`](../bootstrap-aws/README.md).
- `docs/`
  - [`Orchestration.md`](Orchestration.md)
  - [`WordPress.md`](WordPress.md)
