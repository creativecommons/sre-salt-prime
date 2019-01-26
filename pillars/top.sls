{% set HST, POD, LOC = grains.id.split("__") -%}
{% set LOC = LOC.replace("_master", "") -%}
{% set POD__LOC = "{}__{}".format(POD, LOC) -%}
{% set HST__POD = "{}__{}".format(HST, POD) -%}
{% set DIR = "/srv/{}/pillars/{{}}/{{}}/init.sls".format(saltenv) -%}
{% set FILE = "/srv/{}/pillars/{{}}/{{}}.sls".format(saltenv) -%}
{# The following {{ saltenv }} together with the pillarenv_from_saltenv: True
 # configuration value allows the use of development environments without
 # impacting/destabilizing the base environment
-#}
{{ saltenv }}:
  '*':
    # 0. Global (all Minions)
    - letsencrypt
    - postfix.secrets
    - salt
    - user
    - user.passwords.*

    # 1. LOC (location)
{%- if (salt["file.file_exists"](DIR.format("1_LOC", LOC)) or
        salt["file.file_exists"](FILE.format("1_LOC", LOC))) %}
    - 1_LOC.{{ LOC }}
{%- else %}
    # - None
{%- endif %}

    # 2. POD (pod/group)
{%- if (salt["file.file_exists"](DIR.format("2_POD", POD)) or
        salt["file.file_exists"](FILE.format("2_POD", POD))) %}
    - 2_POD.{{ POD }}
{%- else %}
    # - None
{%- endif %}

    # 3. HST (host/role)
{%- if (salt["file.file_exists"](DIR.format("3_HST", HST)) or
        salt["file.file_exists"](FILE.format("3_HST", HST))) %}
    - 3_HST.{{ HST }}
{%- else %}
    # - None
{%- endif %}

    # 4. POD__LOC (pod/group and location)
{%- if (salt["file.file_exists"](DIR.format("4_POD__LOC", POD__LOC)) or
        salt["file.file_exists"](FILE.format("4_POD__LOC", POD__LOC))) %}
    - 4_POD__LOC.{{ POD__LOC }}
{%- else %}
    # - None
{%- endif %}

    # 5. HST__POD (host/role and pod/group)
{%- if (salt["file.file_exists"](DIR.format("5_HST__POD", HST__POD)) or
        salt["file.file_exists"](FILE.format("5_HST__POD", HST__POD))) %}
    - 5_HST__POD.{{ HST__POD }}
{%- else %}
    # - None
{%- endif %}
