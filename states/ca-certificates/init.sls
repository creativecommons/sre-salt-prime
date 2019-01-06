{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - ca-certificates


{{ sls }} update:
  cmd.wait:
    - name: /usr/sbin/update-ca-certificates
