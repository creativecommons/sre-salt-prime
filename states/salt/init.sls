include:
  - .minion
{% if salt.match.glob("salt-prime__*") %}
  - .prime
{% endif %}


{% set repo_url = "https://repo.saltstack.com/apt/debian/9/amd64/latest" -%}
{{ sls }} SaltStack Repository:
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


{{ sls }} manage SaltStack Repository file mode:
  file.managed:
    - name: /etc/apt/sources.list.d/saltstack.list
    - mode: '0444'
    - replace: False
    - require:
      - pkgrepo: {{ sls }} SaltStack Repository
