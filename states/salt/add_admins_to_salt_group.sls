# adding admins to salt group

{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - awscli
      - colordiff
      - git
      - git-crypt
      - git-doc
      - ipv6calc
      - python3-boto
      - python3-boto3
      - python3-git
      - salt-master
      - salt-ssh
 

{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}

{{ sls }} salt group:
  group.present:
    - name: salt
    - gid: 118
    - addusers:
    - require:
      - pkg: {{ sls }} installed_packages
{%- if admins %}
{%- for username in admins %}
  - require:
    - user: user.admins.{{ username }} user
{%- endfor %}
{%- endif %}


