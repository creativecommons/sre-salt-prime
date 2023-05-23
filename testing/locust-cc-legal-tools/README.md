# locust-cc-legal-tools

Performance testing for CC Legal Tools.

:warning: **Use of this code against Creative Commons infrastructure by persons
not explicitly authorized by Creative Commons constitutes abuse.**


## Installation

1. Install dependencies
   - [pipenv][pipenvdocs]
   - macOS:
     - [Installing Locust on macOS - Installation — Locust
       documentation][locustdocs]
1. Install locust via pipenv:
    ```shell
    pipenv install
    ```

[pipenvdocs]: https://pipenv.readthedocs.io/en/latest/
[locustdocs]: https://docs.locust.io/en/stable/installation.html#installing-locust-on-macos


### pipenv Troubleshooting

`pipenv` doesn't always provide the best error messages ([Provide better error
message if the project’s virtual environment is broken][pipenverror]). If all
else fails, try removing the virtual environment and reinstalling:
1. `pipenv --rm`
2. `pipenv install`

[pipenverror]:https://github.com/pypa/pipenv/issues/1918


## Test Execution

```shell
./swarm.sh
```

The helper script, [`swarm.sh`](swarm.sh), assumes macOS.

To test without caching, use your local `/etc/hosts` to change the IP of the
host from the CDN to the origin.


## Primary README

- [`README.md`](../../README.md)
