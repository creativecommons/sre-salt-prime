include:
{% if salt.match.glob("salt-prime__*") %}
  - .prime
{% else %}
  # Not included on the salt-prime server. On the salt-prime server the salt
  # packages should be upgraded manually (and then minion_target_version pillar
  # updated).
  - .minion
{% endif %}

{% set repo_url = "https://repo.saltstack.com/apt/debian/9/amd64/latest" -%}
{{ sls }} SaltStack Package Repo:
  pkgrepo.managed:
    - name: deb {{ repo_url }}  stretch main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: {{ repo_url }}/SALTSTACK-GPG-KEY.pub
    - clean_file: True
    - require:
      - pkg: common installed packages
    - require_in:
{% if salt.match.glob("salt-prime__*") %}
      - pkg: salt.prime installed packages
{% else %}
      - pkg: salt.minion upgrade minion
{% endif %}

/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - mode: '0444'
    - replace: False
    - require:
      - pkgrepo: {{ sls }} SaltStack Package Repo
