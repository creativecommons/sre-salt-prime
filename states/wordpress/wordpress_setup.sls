# Initial wordpress setup, this file copies the wpcli script on the destination server and execute it

{% set ADMIN_USER = salt.pillar.get("wordpress:admin_user", false) -%}
{% set ADMIN_PASS = salt.pillar.get("wordpress:admin_pass", false) -%}
{% set ADMIN_EMAIL = salt.pillar.get("wordpress:admin_email", false) -%}

{% if ADMIN_USER and ADMIN_PASS and ADMIN_EMAIL -%}
{{ sls }} install wpcli script:
  file.managed:
    - name: /usr/local/bin/wpcli.sh
    - source: salt://wordpress/files/wpcli.sh
    - mode: '0775'
    - user: root
    - cmd.run: /usr/local/bin/wpcli.sh '{{ ADMIN_USER }}' '{{ ADMIN_PASS }}' '{{ ADMIN_EMAIL }}'
{% endif %}
