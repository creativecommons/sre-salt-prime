letsencrypt:
  domainsets:
    creativecommons.dk:
      - creativecommons.dk
      - www.creativecommons.dk
    creativecommons.engineering:
      - api.creativecommons.engineering
      - api-dev.creativecommons.engineering
      - search-dev.creativecommons.engineering
      - search-prod.creativecommons.engineering
    creativecommons.ru:
      - creativecommons.ru
      - www.creativecommons.ru
    redirects.creativecommons.org:
      - au-beta.creativecommons.org
      - br.creativecommons.org
      - ca-beta.creativecommons.org
      - ca.creativecommons.org
      - ccsearch.creativecommons.org
      - chapters.creativecommons.org
      - co.creativecommons.org
      - code.creativecommons.org
      - de.creativecommons.org
      - donate.creativecommons.org
      - i.creativecommons.org
      - it.creativecommons.org
      - jp.creativecommons.org
      - ke-beta.creativecommons.org
      - mx-beta.creativecommons.org
      - mx.creativecommons.org
      - newsearch.creativecommons.org
      - nl-beta.creativecommons.org
      - nl.creativecommons.org
      - pl.creativecommons.org
      - search.creativecommons.org
      - sotc.creativecommons.org
      - sv.creativecommons.org
      - za.creativecommons.org
    redirects.sciencecommons.org:
      - scholars.sciencecommons.org
nginx:
  redirect_default: redirects.creativecommons.org
  redirects:
    # creativecommons.dk
    - crt: creativecommons.dk
      src: creativecommons.dk
      dst: dk.creativecommons.net
    - crt: creativecommons.dk
      src: www.creativecommons.dk
      dst: dk.creativecommons.net
    # creativecommons.ru
    - crt: creativecommons.ru
      src: creativecommons.ru
      dst: network.creativecommons.org/chapter
    - crt: creativecommons.ru
      src: www.creativecommons.ru
      dst: network.creativecommons.org/chapter
    # redirects.creativecommons.org
    - crt: redirects.creativecommons.org
      src: au-beta.creativecommons.org
      dst: au-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: br.creativecommons.org
      dst: br.creativecommons.net
    - crt: redirects.creativecommons.org
      src: ca-beta.creativecommons.org
      dst: ca-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: ca.creativecommons.org
      dst: ca.creativecommons.net
    - crt: redirects.creativecommons.org
      src: ccsearch.creativecommons.org
      dst: search.creativecommons.org
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
      src: de.creativecommons.org
      dst: de.creativecommons.net
    - crt: redirects.creativecommons.org
      src: donate.creativecommons.org
      dst: classy.org/give/313412/#!/donation/checkout
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
      src: newsearch.creativecommons.org
      dst: search.creativecommons.org
    - crt: redirects.creativecommons.org
      src: mx.creativecommons.org
      dst: mx.creativecommons.net
    - crt: redirects.creativecommons.org
      src: mx-beta.creativecommons.org
      dst: mx.creativecommons.net
    - crt: redirects.creativecommons.org
      src: nl-beta.creativecommons.org
      dst: nl-beta.creativecommons.net
    - crt: redirects.creativecommons.org
      src: nl.creativecommons.org
      dst: creativecommons.nl
    - crt: redirects.creativecommons.org
      src: pl.creativecommons.org
      dst: creativecommons.pl
    - crt: redirects.creativecommons.org
      src: sotc.creativecommons.org
      dst: stateof.creativecommons.org
    - crt: redirects.creativecommons.org
      src: sv.creativecommons.org
      dst: sv.creativecommons.net
    - crt: redirects.creativecommons.org
      src: za.creativecommons.org
      dst: za.creativecommons.net
    # redirects.sciencecommons.org
    - crt: redirects.sciencecommons.org
      src: scholars.sciencecommons.org
      dst: labs.creativecommons.org/scholars
