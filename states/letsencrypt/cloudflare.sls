{{ sls }} root secrets dir:
  file.directory:
    - name: /root/.secrets
    - mode: '0400'


{{ sls }} cloudflare_api.ini:
  file.managed:
    - name: /root/.secrets/cloudflare_api.ini
    - contents:
      - '# Managed by SaltStack'
      - 'dns_cloudflare_email = "{{ pillar.cloudflare.email }}"'
      - 'dns_cloudflare_api_key = "{{ pillar.cloudflare. api_key }}"'
    - mode: '0400'


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - python-pip


{{ sls }} install certbot-dns-cloudflare:
  pip.installed:
    - name: certbot-dns-cloudflare == {{ pillar.letsencrypt.version }}
    - require:
      - pkg: {{ sls }} installed packages
      - file: {{ sls }} cloudflare_api.ini
    - require_in:
      - pip: letsencrypt install certbot