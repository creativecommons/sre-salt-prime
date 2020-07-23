include:
  - 5_HST__POD.cclicdev__stage.secrets

letsencrypt:
  domainsets:
    cclicdev.creativecommons.org:
      - cclicdev.creativecommons.org
nginx:
  cert_name: cclicdev.creativecommons.org
states:
  sudo.dangerdev: {{ sls }}
