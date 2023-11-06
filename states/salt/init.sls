{% set HST = pillar.hst -%}
{% set OS = grains['oscodename'] -%}

include:
  - .minion
{%- if salt.match.glob("salt-prime__*") %}
  - .prime
{%- endif %}


{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - gnupg


{% if HST == "salt-prime" or grains['osmajorrelease'] > 11 %}
{% set salt_version_major = "3006" %}
{% set salt_gpg_key = "SALT-PROJECT-GPG-PUBKEY-2023.pub" %}
{% set repo_url = ("https://repo.saltproject.io/salt/py3/debian/{}/amd64/{}"
                   .format(grains['osmajorrelease'], salt_version_major)) -%}
{% else -%}
{% set salt_version_major = pillar.salt.minion_target_version[0:4] -%}
{% set salt_gpg_key = "SALTSTACK-GPG-KEY.pub" %}
{% set repo_url = ("https://repo.saltproject.io/py3/debian/{}/amd64/{}"
                   .format(grains['osmajorrelease'], salt_version_major)) -%}
{% endif -%}
{{ sls }} SaltStack Repository:
  pkgrepo.managed:
    - name: deb {{ repo_url }} {{ OS }} main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: {{ repo_url }}/{{ salt_gpg_key }}
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
{%- if salt.match.glob("salt-prime__*") %}
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
