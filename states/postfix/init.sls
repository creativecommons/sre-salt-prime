{% import "postfix/jinja2.sls" as pf with context -%}


include:
  - tls


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - libsasl2-modules
      - postfix
      - postfix-doc


{{ sls }} service:
  service.running:
    - name: postfix
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} main.cf:
  file.managed:
    - name: /etc/postfix/main.cf
    - source: salt://postfix/files/main.cf
    - mode: '0644'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: {{ sls }} service


{{ pf.install_alias(sls, "0444", "/etc/aliases", "aliases") -}}
{{ pf.install_map(sls, "0400", "/etc/postfix/sasl_passwd", "sasl_passwd") -}}
{% if pillar.hst == "cclicdev" and pillar.pod.startswith("stage") -%}
{{ pf.install_map(sls, "0400", "/etc/postfix/transport",
                  "transport_stage_caktus") -}}
{% elif pillar.pod.startswith("stage") -%}
{{ pf.install_map(sls, "0400", "/etc/postfix/transport", "transport_stage") -}}
{% endif -%}
