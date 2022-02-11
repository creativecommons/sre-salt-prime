# Also see the www-data group stanza in:
# - states/apache2/init.sls
# - states/nginx/init.sls


{% set admins = pillar.user.admins.keys()|sort %}
{%- for username in admins %}
{%- set userdata = pillar.user.admins[username] %}


{{ sls }} {{ username }} group:
  group.present:
    - name: {{ username }}
    - gid: {{ userdata.id }}


{{ sls }} {{ username }} user:
  user.present:
    - name: {{ username }}
    - uid: {{ userdata.id }}
    - gid: {{ username }}
    - fullname: {{ userdata.fullname }}
    - shell: {{ userdata.shell }}
    - password: '{{ pillar.user.passwords[username] }}'
    - require:
      - group: {{ sls }} {{ username }} group


{%- set ed25519 = salt.pillar.get(
  "user:admins:{}:sshpub:ed25519".format(username), none) %}
{%- set rsa = salt.pillar.get(
  "user:admins:{}:sshpub:rsa".format(username), none) %}
{%- if ed25519 %}
{%- for pubkey in ed25519|sort %}


{{ sls }} {{ username }} sshauth ed25519 {{ loop.index }}:
  ssh_auth:
    - present
    - user: {{ username }}
    - enc: ed25519
    - source: salt://user/files/{{ pubkey }}
    - require:
      - user: {{ sls }} {{ username }} user
{%- endfor %}


{%- elif rsa %}
{%- for pubkey in rsa|sort %}


{{ sls }} {{ username }} sshauth rsa {{ loop.index }}:
  ssh_auth:
    - present
    - user: {{ username }}
    - enc: rsa
    - source: salt://user/files/{{ pubkey }}
    - require:
      - user: {{ sls }} {{ username }} user
{%- endfor %}
{%- endif %}
{%- endfor %}


{%- for group in pillar.user.admin_groups|sort %}


{{ sls }} {{ group }} group:
  group.present:
    - name: {{ group }}
    - system: True
    - addusers:
{%- for username in admins %}
      - {{ username }}
{%- endfor %}
    - require:
{%- for username in admins %}
      - user: {{ sls }} {{ username }} user
{%- endfor %}


{%- endfor %}
