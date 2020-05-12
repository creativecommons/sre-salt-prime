# Also see the www-data group stanza in:
# - states/apache2/init.sls
# - states/nginx/init.sls


{%- for username in pillar.user.webdevs.keys()|sort %}
{%- set userdata = pillar["user"]["webdevs"][username] %}
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


{# This assumes a Debian osrelease_info -#}
{% if ("ed25519" in userdata.sshpub and
       grains["saltversioninfo"][0] > 2014 and
       grains["osrelease_info"][0] > 7) -%}
{% for pubkey in userdata.sshpub.ed25519 -%}
{{ sls }} {{ username }} sshauth ed25519 {{ loop.index }}:
  ssh_auth:
    - present
    - user: {{ username }}
    - enc: ed25519
    - source: salt://user/files/{{ pubkey }}
    - require:
      - user: {{ sls }} {{ username }} user


{% endfor -%}
{% else -%}
{% for pubkey in userdata.sshpub.rsa -%}
{{ sls }} {{ username }} sshauth rsa {{ loop.index }}:
  ssh_auth:
    - present
    - user: {{ username }}
    - enc: rsa
    - source: salt://user/files/{{ pubkey }}
    - require:
      - user: {{ sls }} {{ username }} user


{% endfor -%}
{% endif -%}
{% endfor -%}


{% for group in pillar.user.webdev_groups -%}
{{ sls }} {{ group }} group:
  group.present:
    - name: {{ group }}
    - system: True
    - addusers:
{%- for webdev in pillar.user.webdevs.keys() %}
      - {{ webdev }}
{%- endfor %}
    - require:
{%- for webdev in pillar.user.webdevs.keys() %}
      - user: {{ sls }} {{ webdev }} user
{%- endfor %}


{% endfor -%}


{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}
{% set webdevs = salt["pillar.get"]("user:webdevs", {}).keys()|sort -%}
{% set users = admins + webdevs|sort -%}
{{ sls }} webdev group:
  group.present:
    - name: webdev
    - gid: {{ pillar.groups.webdev }}
    - addusers:
{%- for username in users %}
      - {{ username }}
{%- endfor %}
    - require:
{%- if admins %}
{%- for username in admins %}
      - user: user.admins {{ username }} user
{%- endfor %}
{%- endif %}
{%- if webdevs %}
{%- for username in webdevs %}
      - user: {{ sls }} {{ username }} user
{%- endfor %}
{%- endif %}
