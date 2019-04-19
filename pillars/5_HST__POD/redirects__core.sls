letsencrypt:
  domainsets:
    redirects.creativecommons.org:
      - redirects.creativecommons.org
      # SANs:
      - donate.creativecommons.org
      - i.creativecommons.org
nginx:
  redirects:
    - src: donate.creativecommons.org
      dst: us.netdonor.net/page/6650/donate/1
    - src: i.creativecommons.org
      dst: licensebuttons.net
