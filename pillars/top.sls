{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set LOOKUP = {"1_LOC": ["(location)", LOC],
                 "2_POD": ["(pod/group)", POD],
                 "3_HST": ["(host/role)", HST],
                 "4_POD__LOC": ["(pod/group and location)", POD__LOC],
                 "5_HST__POD": ["(host/role and pod/group)", HST__POD]} -%}
{# The following {{ saltenv }} together with the pillarenv_from_saltenv: True
 # configuration value allows the use of development environments without
 # impacting/destabilizing the base environment
-#}
{{ saltenv }}:
  '*':
    # 0. Global (all Minions)
    - classification
    - letsencrypt
    - postfix.secrets
    - salt
    - user
    - user.passwords.*
{%- for key in LOOKUP.keys()|sort %}
{%- set data = LOOKUP[key] %}
{%- set lookup_init = "{}/{}/init.sls".format(key, data[1]) %}
{%- set lookup_sls = "{}/{}.sls".format(key, data[1]) %}
    # {{ key }} {{ data[0]}}
{%- if (salt["pillar.file_exists"](lookup_init, saltenv=saltenv) or
        salt["pillar.file_exists"](lookup_sls, saltenv=saltenv)) %}
    - {{ key }}.{{ data[1] }}
{%- else %}
    # - None
{%- endif %}
{%- endfor %}
