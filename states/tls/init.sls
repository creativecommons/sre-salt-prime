{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - openssl
      - ssl-cert


{{ sls }} update-ca-certificates:
  cmd.wait:
    - name: /usr/sbin/update-ca-certificates


{{ sls }} generate Diffie-Hellman group:
  cmd.run:
    - name: openssl dhparam -out dhparams.pem 2048
    - cwd: /etc/ssl/private
    - creates: /etc/ssl/private/dhparams.pem
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} dhparams.pem:
  file.managed:
    - name: /etc/ssl/private/dhparams.pem
    - user: root
    - group: ssl-cert
    - mode: '0440'
    - replace: False
    - require:
      - cmd: {{ sls }} generate Diffie-Hellman group
