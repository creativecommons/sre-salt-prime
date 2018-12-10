{%- for role in pillar.get('roles', []) %}
01-roles/{{ role }}.yaml
{%- endfor %}
