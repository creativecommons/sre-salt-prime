# Bootstrap AWS


## Overview

The `bootstrap.sh` script uses a local salt install to bootstrap an AWS
VPC environment with a Salt Manager EC instance (minimum infrastructure on
which all future SaltStack management development can take place).


## macOS Installation

1. Install SaltStack:

    ```shell
    brew install salt
    ```

2. Install boto and boto3 within SaltStack install:

    ```shell
    /usr/local/Cellar/salt/2018.3.2/libexec/bin/pip install boto boto3
    ```

3. Configure AWS CLI with named profile of `creativecommons`

   - [Configuring the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

4. Determine Availability Zones:

    ```shell
    aws ec2 describe-availability-zones --region us-east-2 --profile creativecommons
    ```

5. Verify Parameters at top of `core.sls`


## Create Core Infrastructure on AWS

6. Create VPC and related resources:

    ```shell
    LOG_LEVEL=info TEST=True ./bootstrap.sh
    ```

   - Use `TEST=False` after verifying run to effect changes
   - Expected/ignorable warning:

    ```
    [WARNING ] /usr/local/Cellar/salt/2018.3.2/libexec/lib/python2.7/site-packages/salt/modules/boto_vpc.py:2487: DeprecationWarning: The 'describe_route_table' method has been deprecated and replaced by 'describe_route_tables'.

    ```
