letsencrypt:
  domainsets:
    creativecommons.dk:
      - creativecommons.dk
      - www.creativecommons.dk
    api.creativecommons.engineering:
      - api.creativecommons.engineering
      - api-dev.creativecommons.engineering
      - search.creativecommons.engineering
      - search-dev.creativecommons.engineering
      - search-prod.creativecommons.engineering
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
      - e-donate.creativecommons.org
      - i.creativecommons.org
      - it.creativecommons.org
      - jp.creativecommons.org
      - ke-beta.creativecommons.org
      - mx-beta.creativecommons.org
      - mx.creativecommons.org
      - newsearch.creativecommons.org
      - nl-beta.creativecommons.org
      - nl.creativecommons.org
      - oldsearch.creativecommons.org
      - pl.creativecommons.org
      - slack-signup.creativecommons.org
      - sotc.creativecommons.org
      - support.creativecommons.org
      - sv.creativecommons.org
      - za.creativecommons.org
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
      dst: network.creativecommons.org/chapter
      dst: network.creativecommons.org/chapter
    # redirects.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: au-beta.creativecommons.org
      dst: au-beta.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: br.creativecommons.org
      dst: br.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: ca-beta.creativecommons.org
      dst: ca-beta.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: ca.creativecommons.org
      dst: ca.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: ccsearch.creativecommons.org
      dst: search.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: co.creativecommons.org
      dst: co.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: code.creativecommons.org
      dst: opensource.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: chapters.creativecommons.org
      dst: creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: de.creativecommons.org
      dst: de.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: donate.creativecommons.org
      dst: classy.org/give/313412/#!/donation/checkout
    - crt: redirects.creativecommons.org-0001
      src: e-donate.creativecommons.org
      dst: 'classy.org/give/313412/#!/donation/checkout'
      ignore_request_uri: true
    - crt: redirects.creativecommons.org-0001
      src: i.creativecommons.org
      dst: licensebuttons.net
    - crt: redirects.creativecommons.org-0001
      src: it.creativecommons.org
      dst: creativecommons.it
    - crt: redirects.creativecommons.org-0001
      src: jp.creativecommons.org
      dst: creativecommons.jp
    - crt: redirects.creativecommons.org-0001
      src: ke-beta.creativecommons.org
      dst: ke-beta.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: newsearch.creativecommons.org
      dst: search.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: mx.creativecommons.org
      dst: mx.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: mx-beta.creativecommons.org
      dst: mx.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: nl-beta.creativecommons.org
      dst: nl-beta.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: nl.creativecommons.org
      dst: creativecommons.nl
    - crt: redirects.creativecommons.org-0001
      src: oldsearch.creativecommons.org
      dst: search.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: pl.creativecommons.org
      dst: creativecommons.pl
    - crt: redirects.creativecommons.org-0001
      src: slack-signup.creativecommons.org
      dst: communityinviter.com/apps/creativecommons/cc
      ignore_request_uri: true
    - crt: redirects.creativecommons.org-0001
      src: support.creativecommons.org
      dst: classy.org/give/313412/#!/donation/checkout
      ignore_request_uri: true
    - crt: redirects.creativecommons.org-0001
      src: sotc.creativecommons.org
      dst: stateof.creativecommons.org
    - crt: redirects.creativecommons.org-0001
      src: sv.creativecommons.org
      dst: sv.creativecommons.net
    - crt: redirects.creativecommons.org-0001
      src: za.creativecommons.org
      dst: za.creativecommons.net
    #    api.creativecommons.engineering has custom configuration, see state
    # search.creativecommons.engineering has custom configuration, see state
