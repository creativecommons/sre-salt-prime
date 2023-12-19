{% set HST = pillar.hst -%}
{% set SALT_VERSION_MAJOR = pillar.salt.minion_target_version -%}


include:
  - .minion
{%- if HST == "salt-prime" %}
  - .prime
{%- endif %}


{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - gnupg


{# As of 2023-11-15, Salt does not maintain a Debian repository for Debian 12
 # (Bookworm). Also see: https://github.com/saltstack/salt/issues/64223
-#}
{% if HST == "salt-prime" or grains['osmajorrelease'] > 11 -%}
{% set repo_os  = "bullseye" -%}
{% set salt_gpg_key = "SALT-PROJECT-GPG-PUBKEY-2023.pub" -%}
{% set SALT_VERSION_MAJOR = "3006" -%}
{# uses variables defined above -#}
{% set repo_url = ("https://repo.saltproject.io/salt/py3/debian/11/amd64/3006"
                   .format(grains['osmajorrelease'], SALT_VERSION_MAJOR)) -%}
{% elif SALT_VERSION_MAJOR == 3006.5 -%}
{% set repo_os  = "bullseye" -%}
{% set salt_gpg_key = "SALT-PROJECT-GPG-PUBKEY-2023.pub" -%}
{% set SALT_VERSION_MAJOR = "3006" -%}
{# uses variables defined above -#}
{% set repo_url = ("https://repo.saltproject.io/salt/py3/debian/11/amd64/3006"
                   .format(grains['osmajorrelease'], SALT_VERSION_MAJOR)) -%}
{% else -%}
{% set repo_os = grains['oscodename'] -%}
{% set salt_gpg_key = "SALTSTACK-GPG-KEY.pub" -%}
{# uses variables defined above -#}
{% set repo_url = ("https://repo.saltproject.io/salt/py3/debian/{}/amd64/{}"
                   .format(grains['osmajorrelease'], SALT_VERSION_MAJOR)) -%}
{% endif -%}
{{ sls }} SaltStack Repository:
  pkgrepo.managed:
    - name: deb {{ repo_url }} {{ repo_os }} main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: {{ repo_url }}/{{ salt_gpg_key }}
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
{%- if HST == "salt-prime" %}
      - pkg: salt.prime installed packages
{%- else %}
      - pkg: salt.minion installed packages
      - cmd: salt.minion upgrade minion
{%- endif %}


{{ sls }} manage SaltStack Repository file mode:
  file.managed:
    - name: /etc/apt/sources.list.d/saltstack.list
    - mode: '0444'
    - replace: False
    - require:
      - pkgrepo: {{ sls }} SaltStack Repository
