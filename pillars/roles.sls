# Use salt.modules.match.filter_by to filter minion_id into a role variable
{% set roles = salt['match.filter_by']({
    "salt-prime*": ["salt-prime"],
    "bastion-us-east-2*": ["bastion", "saltportforward"],
    "bastion*": ["bastion"],
}) -%}
# Make the role variable available to Pillar:
roles: {{ roles | yaml() }}
