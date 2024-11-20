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
{% set arch_value = "arch=amd64" -%}
{% set pkg_state = "stable" -%}
{% set repo_path = "https://packages.broadcom.com/artifactory" -%}
{% set salt_deb_repo = "saltproject-deb" -%}
{% set salt_gpg_key = "api/security/keypair/SaltProjectKey/public" -%}
{% set signed_key = "signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.pgp" -%}
{% set repo_url = ("{}/{}/".format(
  repo_path, salt_deb_repo)) -%}

{#
 # Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details. migrate to the new recommended approach, which involves storing GPG keys in /etc/apt/keyrings/
-#}
{{ sls }} create keyrings directory:
  file.directory:
    - name: /etc/apt/keyrings
    - mode: '0755'
    - makedirs: True

{{ sls }} download public Salt GPG key:
  cmd.run:
    - name: curl -fsSL {{ repo_path }}/{{ salt_gpg_key }} | sudo tee /etc/apt/keyrings/salt-archive-keyring-2023.pgp
    - unless: test -f /etc/apt/keyrings/salt-archive-keyring-2023.pgp
    - require:
      - file: {{ sls }} create keyrings directory
      - pkg: {{ sls }} dependencies

{{ sls }} SaltStack Repository:
  pkgrepo.managed:
    - name: deb [{{arch_value}} {{signed_key}}] {{ repo_url }} {{ pkg_state }} main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: /etc/apt/keyrings/salt-archive-keyring-2023.pgp
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
      - cmd: {{ sls }} download public Salt GPG key
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
