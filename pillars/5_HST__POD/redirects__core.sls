letsencrypt:
  domainsets:
    redirects.creativecommons.org:
      - au-beta.creativecommons.org
      - ca-beta.creativecommons.org
      - chapters.creativecommons.org
      - donate.creativecommons.org
      - i.creativecommons.org
      - it.creativecommons.org
      - jp.creativecommons.org
      - ke-beta.creativecommons.org
      - mx-beta.creativecommons.org
      - nl.creativecommons.org
      - nl-beta.creativecommons.org
      - pl.creativecommons.org
      - sotc.creativecommons.org
nginx:
  redirects:
    - src: au-beta.creativecommons.org
      dst: au-beta.creativecommons.net
    - src: ca-beta.creativecommons.org
      dst: ca-beta.creativecommons.net
    - src: chapters.creativecommons.org
      dst: creativecommons.net
    - src: donate.creativecommons.org
      dst: us.netdonor.net/page/6650/donate/1
    - src: i.creativecommons.org
      dst: licensebuttons.net
    - src: it.creativecommons.org
      dst: creativecommons.it
    - src: jp.creativecommons.org
      dst: creativecommons.jp
    - src: ke-beta.creativecommons.org
      dst: ke-beta.creativecommons.net
    - src: mx-beta.creativecommons.org
      dst: mx-beta.creativecommons.net
    - src: nl.creativecommons.org
      dst: creativecommons.nl
    - src: nl-beta.creativecommons.org
      dst: nl-beta.creativecommons.net
    - src: pl.creativecommons.org
      dst: creativecommons.pl
    - src: sotc.creativecommons.org
      dst: stateof.creativecommons.org
