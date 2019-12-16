letsencrypt:
  domainsets:
    stage.creativecommons.org:
      - stage.creativecommons.org
nginx:
  cert_name: stage.creativecommons.org
  dispatches:
    # CC Engine
    - description: CC Engine
      location: /characteristic
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /choose
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /licenses
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /ns
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /publicdomain
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /rdf
      server: http://127.0.0.1:8503
    - description: CC Engine
      location: /schema.rdf
      server: http://127.0.0.1:8503
    # Miscellaneous
    - description: Miscellaneous
      location: /faq
      server: http://127.0.0.1:8503
    - description: Miscellaneous
      location: /platform/toolkit
      server: http://127.0.0.1:8503
    # WordPress (Default)
    - description: Default (WordPress)
      location: /
      server: http://127.0.0.1:8503
