letsencrypt:
  domainsets:
    redirects.creativecommons.org:
      - au-beta.creativecommons.org
      - ca-beta.creativecommons.org
      - chapters.creativecommons.org
      - co.creativecommons.org
      - code.creativecommons.org
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
      - za.creativecommons.org
    redirects.sciencecommons.org:
      - scholars.sciencecommons.org
nginx:
  redirect_default: redirects.creativecommons.org
  redirects:
    # redirects.creativecommons.org
    - crt: redirects.creativecommons.org
      src: au-beta.creativecommons.org
      dst: au-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: ca-beta.creativecommons.org
      dst: ca-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: co.creativecommons.org
      dst: co.creativecommons.net
    - crt: redirects.creativecommons.org
      src: code.creativecommons.org
      dst: opensource.creativecommons.org
    - crt: redirects.creativecommons.org
      src: chapters.creativecommons.org
      dst: creativecommons.net
    - crt: redirects.creativecommons.org
      src: donate.creativecommons.org
      dst: us.netdonor.net/page/6650/donate/1
    - crt: redirects.creativecommons.org
      src: i.creativecommons.org
      dst: licensebuttons.net
    - crt: redirects.creativecommons.org
      src: it.creativecommons.org
      dst: creativecommons.it
    - crt: redirects.creativecommons.org
      src: jp.creativecommons.org
      dst: creativecommons.jp
    - crt: redirects.creativecommons.org
      src: ke-beta.creativecommons.org
      dst: ke-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: mx-beta.creativecommons.org
      dst: mx-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: nl.creativecommons.org
      dst: creativecommons.nl
    - crt: redirects.creativecommons.org
      src: nl-beta.creativecommons.org
      dst: nl-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: pl.creativecommons.org
      dst: creativecommons.pl
    - crt: redirects.creativecommons.org
      src: sotc.creativecommons.org
      dst: stateof.creativecommons.org
    - crt: redirects.creativecommons.org
      src: za.creativecommons.org
      dst: za.creativecommons.net
    # redirects.sciencecommons.org
    - crt: redirects.sciencecommons.org
      src: scholars.sciencecommons.org
      dst: labs.creativecommons.org/scholars

