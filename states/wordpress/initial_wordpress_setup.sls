# Initial wordpress setup, this file copies the wpcli script on the destination server and execute it

{% set ADMIN_USER = salt.pillar.get("wordpress:admin_user", false) -%}
{% set ADMIN_PASS = salt.pillar.get("wordpress:admin_pass", false) -%}
{% set ADMIN_EMAIL = salt.pillar.get("wordpress:admin_email", false) -%}
{% set POD = pillar.pod -%}
{% if POD.startswith("stage") -%}
{% set WEBNAME = "stage.creativecommons.org" -%}
{% else -%}
{% set WEBNAME = "creativecommons.org" -%}
{% endif %}



{% if ADMIN_USER and ADMIN_PASS and ADMIN_EMAIL -%}
{{ sls }} install wpcli script:
  file.managed:
    - name: /usr/local/bin/wpcli
    - source: salt://wordpress/files/wpcli
    - mode: '0775'
    - user: root

{% set wpcli_installed = salt['cmd.run_all']('wpcli --no-color --quiet core is-installed') %}

{% if wpcli_installed.retcode == 0 %}
{{ sls }} wpcli_already_installed:
    cmd.run:
      - name: echo 'already installed'
{% else %}
{{ sls }} wpcli_not_installed:
  cmd.run:
    - name: echo 'not installed'
#{{ sls }} run wpcli script:
#    cmd.run:
#      - name: /usr/local/bin/wpcli '{{ ADMIN_USER }}' '{{ ADMIN_PASS }}' '{{ ADMIN_EMAIL }}' '{{ WEBNAME  }}' 
#      - user: root
#      - require:
#        - file: {{ sls }} install wpcli script 
{% endif %}
{% endif %}
