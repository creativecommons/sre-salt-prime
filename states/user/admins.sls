{% for username in pillar["user"]["admins"].keys() %}
{% set userdata = pillar["user"]["admins"][username] %}
{{ username }}:
  group:
    - present
    - gid: {{ userdata["id"] }}
  user:
    - present
    - uid: {{ userdata["id"] }}
    - gid_from_name: True
    - fullname: {{ userdata["fullname"] }}
    - shell: {{ userdata["shell"] }}
    - groups:
{%- for group in pillar["user"]["admin_groups"] %}
        - {{ group -}}
{% endfor %}
    - password: '{{ pillar["user"]["passwords"][username] }}'
    - require:
        - group: {{ username -}}
{% endfor %}


{% if (grains["saltversioninfo"][0] > 2014 and
       grains["osrelease_info"][0] > 7) -%}
timidrobot-ed25519:
  ssh_auth:
    - present
    - user: timidrobot
    - enc: ed25519
    - source: salt://user/files/timidrobot_ed25519_creativecommons_20181121.pub
    - require:
      - user: timidrobot
{% else %}
timidrobot-rsa:
  ssh_auth:
    - present
    - user: timidrobot
    - enc: rsa
    - source: salt://user/files/timidrobot_rsa_creativecommons_20181018.pub
    - require:
      - user: timidrobot
{% endif %}
