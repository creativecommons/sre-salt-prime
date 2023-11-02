## adding admins to salt group

{% set admins = salt["pillar.get"]("user:admins", {}).keys()|sort -%}

{{ sls }} salt group:
  group.present:
    - name: salt
    - gid: 118
{%- if admins %}
{%- for username in admins %}
      - user: user.admins {{ username }} user
{%- endfor %}
{%- endif %}
