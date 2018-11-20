# Bootstrap AWS


## macOS Laptop Installation

1. Install SaltStack:

    ```shell
brew install salt
    ```

2. Install boto and boto3 within SaltStack install:

    ```shell
/usr/local/Cellar/salt/2018.3.2/libexec/bin/pip install boto boto3
    ```

3. Configure AWS CLI with profile `creativecommons`


## Create Core Infrastructure on AWS

4. Create VPC and related resources:

    ```shell
    LOG_LEVEL=info TEST=True ./bootstrap.sh
    ```
