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


# https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/linux-deb.html


{{ sls }} apt pin Salt version:
  file.managed:
    - name: /etc/apt/preferences.d/salt-pin-1001
    - source: salt://salt/files/salt-pin-1001
    - mode: '0444'


{{ sls }} create keyrings directory:
  file.directory:
    - name: /etc/apt/keyrings
    - mode: '0755'
    - makedirs: True


{{ sls }} Salt project public key:
  file.managed:
    - name: /etc/apt/keyrings/salt-archive-keyring.pgp
    - source: salt://salt/files/salt-archive-keyring.pgp
    - mode: '0444'
    - require:
      - file: {{ sls }} apt pin Salt version
      - file: {{ sls }} create keyrings directory
      - pkg: {{ sls }} dependencies


{{ sls }} Salt project source:
  file.managed:
    - name: /etc/apt/sources.list.d/salt.sources
    - source: salt://salt/files/salt.sources
    - mode: '0444'
    - require:
      - file: {{ sls }} Salt project public key 
      - file: {{ sls }} apt pin Salt version
      - pkg: {{ sls }} dependencies
    - require_in:
{%- if HST == "salt-prime" %}
      - pkg: salt.prime installed packages
{%- else %}
      - pkg: salt.minion installed packages
      - cmd: salt.minion upgrade minion
{%- endif %}
