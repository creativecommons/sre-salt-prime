{% set SERVER_503 = "http://127.0.0.1:8503" -%}
{% set SERVER_CCENGINE = "http://10.22.11.12" -%}
{% set SERVER_MISC = SERVER_503 -%}
{% set SERVER_DEFAULT = SERVER_503 -%}


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
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /choose
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /licenses
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /ns
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /publicdomain
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /rdf
      server: {{ SERVER_CCENGINE }}
    - description: CC Engine
      location: /schema.rdf
      server: {{ SERVER_CCENGINE }}
    # Miscellaneous
    - description: Miscellaneous
      location: /faq
      server: {{ SERVER_MISC }}
    - description: Miscellaneous
      location: /platform/toolkit
      server: {{ SERVER_MISC }}
    # Default (WordPress)
    - description: Default (WordPress)
      location: /
      server: {{ SERVER_DEFAULT }}
