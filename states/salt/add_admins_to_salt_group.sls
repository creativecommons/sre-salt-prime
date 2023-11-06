# adding admins to salt group


{{ sls }} salt group:
  group.present:
    - name: salt
    - gid: 118


{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}
{%- if admins %}
{%- for username in admins %}
{{ username }}:
  user.present:
    - groups:
      - salt  
{%- endfor %}
{%- endif %}
