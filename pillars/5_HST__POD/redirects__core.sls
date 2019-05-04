letsencrypt:
  domainsets:
    redirects.creativecommons.org:
      - donate.creativecommons.org
      - i.creativecommons.org
      - sotc.creativecommons.org
nginx:
  redirects:
    - src: donate.creativecommons.org
      dst: us.netdonor.net/page/6650/donate/1
    - src: i.creativecommons.org
      dst: licensebuttons.net
    - src: sotc.creativecommons.org
      dst: stateof.creativecommons.org
