{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}

{% raw %}
# The following {{ saltenv }} together with the pillarenv_from_saltenv: True
# configuration value allows the use of development environments without
# impacting/destabilizing the base environment
{% endraw %}
{{ saltenv }}:
  '*':
    # Global (all Minions)
    - letsencrypt
    - salt
    - user
    - user.passwords.*
    # Location
    - '*.{{ LOC }}'
    # Pod
    - '*.{{ POD }}'
    # Host
    - '*.{{ HST }}'
  # Names/Roles
  'salt-prime__*':
    # Orchestration Data
    - infra
    - infra.*
    - infra.us-east-2.*
  'pmwiki__*':
    - pmwiki
    - pmwiki.secrets
    - postfix.secrets
  'wikijs__*':
    - wikijs
    - wikijs.secrets
