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


{#
 # As of 2024-11-19, Salt has migrated repository to broadcom
 # Also see: https://saltproject.io/blog/salt-project-package-repo-migration-and-guidance/
-#}
{% set repo_path = "https://packages.broadcom.com/artifactory" -%}
{% set salt_deb_repo = "saltproject-deb" -%}
{% set pkg_state = "stable" -%}
{% set salt_gpg_key = "api/security/keypair/SaltProjectKey/public" -%}
{% set repo_url = ("{}/{}/".format(
  repo_path, salt_deb_repo)) -%}
{{ sls }} SaltStack Repository:
  pkgrepo.managed:
    - name: deb {{ repo_url }} {{ pkg_state }} main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: {{ repo_path }}/{{ salt_gpg_key }}
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
