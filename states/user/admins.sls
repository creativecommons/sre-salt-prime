{% for username in pillar.user.admins.keys() -%}
{% set userdata = pillar["user"]["admins"][username] -%}
{{ sls }} {{ username }} group:
  group.present:
    - name: {{ username }}
    - gid: {{ userdata.id }}


{{ sls }} {{ username }} user:
  user.present:
    - name: {{ username }}
    - uid: {{ userdata.id }}
    - gid_from_name: True
    - fullname: {{ userdata.fullname }}
    - shell: {{ userdata.shell }}
    - password: '{{ pillar["user"]["passwords"][username] }}'
    - require:
      - group: {{ sls }} {{ username }} group


{% endfor -%}


{%- for group in pillar.user.admin_groups %}
{{ sls }} {{ group }} group:
  group.present:
    - name: {{ group }}
    - system: True
    - addusers:
{%- for admin in pillar.user.admins.keys() %}
      - {{ admin }}
{%- endfor %}
    - require:
{%- for admin in pillar.user.admins.keys() %}
      - user: {{ sls }} {{ admin }} user
{%- endfor %}

{% endfor %}

{{ sls }} alden-rsa:
  ssh_auth:
    - present
    - user: alden
    - enc: rsa
    - source: salt://user/files/alden_rsa_creativecommons.org.pub
    - require:
      - user: {{ sls }} alden user


{{ sls }} kgodey-rsa:
  ssh_auth:
    - present
    - user: kgodey
    - enc: rsa
    - source: salt://user/files/kgodey_rsa_kdogey_mayo.hilia.us.pub
    - require:
      - user: {{ sls }} kgodey user


{% if (grains["saltversioninfo"][0] > 2014 and
       grains["osrelease_info"][0] > 7) -%}
{{ sls }} timidrobot-ed25519:
  ssh_auth:
    - present
    - user: timidrobot
    - enc: ed25519
    - source: salt://user/files/timidrobot_ed25519_creativecommons_20181121.pub
    - require:
      - user: {{ sls }} timidrobot user
{% else %}
{{ sls }} timidrobot-rsa:
  ssh_auth:
    - present
    - user: timidrobot
    - enc: rsa
    - source: salt://user/files/timidrobot_rsa_creativecommons_20181018.pub
    - require:
      - user: {{ sls }} timidrobot user
{% endif %}
