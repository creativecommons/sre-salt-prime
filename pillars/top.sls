{% raw %}
# The following {{ saltenv }} together with the pillarenv_from_saltenv: True
# configuration value allows the use of development environments without
# impacting/destabilizing the base environment
{% endraw %}
{{ saltenv }}:
  # Global (all Minions)
  '*':
    - salt
    - user
    - user.passwords.*
  # Location
  '*__*__us-east-2 or *__*__us-east-2_master':
    - location.us-east-2
  # Pod
  '*__core__*':
    - pod.core
  '*__gnwp__*':
    - pod.gnwp
  # Names/Roles
  'salt-prime__*':
    - salt.prime
    # Orchestration Data
    - infra
    - infra.*
    - infra.us-east-2.*
