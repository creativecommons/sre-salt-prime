letsencrypt:
  domainsets:
    redirects.creativecommons.org:
      - redirects.creativecommons.org
      - i.creativecommons.org
nginx:
  redirects:
    - src: i.creativecommons.org
      dst: licensebuttons.net
