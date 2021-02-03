# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
#   tgt_net: Targeted Network
# optional command line pillar data:
#   kms_key_storage: KMS Key ID ARN
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}
{% set NET = pillar.tgt_net -%}

{% set P_LOC = pillar.infra[LOC] -%}

{% if "kms_key_storage" in pillar -%}
{% set KMS_KEY_STORAGE = pillar.kms_key_storage -%}
{% else -%}
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{# The region must NOT be omitted from the KMS Key ID -#}
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", ACCOUNT_ID,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}
{% endif -%}


{{ sls }} EC2 Instance:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - saltenv: {{ saltenv }}
    - concurrent: True
    - sls: orch.aws.ec2_instance_web.instance
    - kwarg:
      pillar:
        tgt_hst: {{ HST }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        tgt_net: {{ NET }}
        conf_sls: {{ sls }}


{{ sls }} EC2 Storage:
  salt.state:
    - tgt: {{ pillar.location.salt_prime_id }}
    - saltenv: {{ saltenv }}
    - sls: orch.aws.ec2_instance_web.storage
    - concurrent: True
    - kwarg:
      pillar:
        tgt_hst: {{ HST }}
        tgt_pod: {{ POD }}
        tgt_loc: {{ LOC }}
        conf_sls: {{ sls }}
        kms_key_storage: {{ KMS_KEY_STORAGE }}
    - require:
      - salt: {{ sls }} EC2 Instance


# Instance creation and storage creation are separate states as the boto
# information does not appear to be updated on instance creation. Without this
# seperation, the following error is encountered:
#
#   An exception occurred in this state: Traceback (most recent call last):
#     File "/usr/lib/python2.7/dist-packages/salt/state.py", line 1981, in call
#       **cdata['kwargs'])
#     File "/usr/lib/python2.7/dist-packages/salt/loader.py", line 1977, in wrapper
#       return f(*args, **kwargs)
#     File "/usr/lib/python2.7/dist-packages/salt/states/boto_ec2.py", line 1410, in volume_present
#       instance = instances[0]
#   IndexError: list index out of range
