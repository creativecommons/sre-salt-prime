{% set HST = pillar.hst -%}
{% set SALT_VERSION_MAJOR = pillar.salt.minion_target_version -%}
{% set REPO_PREFIX = "https://repo.saltproject.io/salt/py3/debian" -%}


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


{% if HST == "salt-prime" or grains['osmajorrelease'] > 11 -%}
{#
 # As of 2023-11-15, Salt does not maintain a Debian repository for Debian 12
 # (Bookworm). Also see: https://github.com/saltstack/salt/issues/64223
-#}
{% set repo_os = "bullseye" -%}
{% set minion_os_major = 11 -%}
{% set SALT_VERSION_MAJOR = 3006 -%}
{% else %}
{% set repo_os = grains['oscodename'] -%}
{% set minion_os_major = grains['osmajorrelease'] -%}
{% endif %}
{% set salt_gpg_key = "SALT-PROJECT-GPG-PUBKEY-2023.pub" -%}
{% set SALT_VERSION_MAJOR = 3006 -%}
{% set repo_url = ("{}/{}/amd64/{}".format(
  REPO_PREFIX, minion_os_major, SALT_VERSION_MAJOR)) -%}
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
