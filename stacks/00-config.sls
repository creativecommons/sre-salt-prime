01-common/user_passwords/*.yaml
{%- for role in pillar.get('roles', []) %}
02-roles/{{ role }}.yaml
{%- endfor %}
