include:
  - wiki


{{ sls }} /srv/wiki/docroot:
  file.directory:
    - name: /srv/wiki/docroot
    - require:
      - file: wiki /srv/wiki


{%- for dir in ["icons", "images", "includes", "legalcode"] %}


{{ sls }} symlink {{ dir }}:
  file.symlink:
    - name: /srv/wiki/docroot/{{ dir }}
    - target: /srv/wiki/src/creativecommons.org/docroot/{{ dir }}
    - require:
      - file: {{ sls }} /srv/wiki/docroot
      - git: wiki.src creativecommons.org repo
    - require_in:
      - test: wiki completed
{%- endfor %}


{{ sls }} dir ns:
  file.directory:
    - name: /srv/wiki/docroot/ns
    - require:
      - file: {{ sls }} /srv/wiki/docroot


{{ sls }} symlink ns.html:
  file.symlink:
    - name: /srv/wiki/docroot/ns/index.html
    - target: ../rdf-meta/ns.html
    - require:
      - file: {{ sls }} dir ns
      - git: wiki.src cc.licenserdf repo
    - require_in:
      - test: wiki completed


{{ sls }} symlink rdf-licenses:
  file.symlink:
    - name: /srv/wiki/docroot/rdf-licenses
    - target: /srv/wiki/src/cc.licenserdf/cc/licenserdf/licenses
    - require:
      - file: {{ sls }} /srv/wiki/docroot
      - git: wiki.src cc.licenserdf repo
    - require_in:
      - test: wiki completed


{{ sls }} symlink rdf-meta:
  file.symlink:
    - name: /srv/wiki/docroot/rdf-meta
    - target: /srv/wiki/src/cc.licenserdf/cc/licenserdf/rdf
    - require:
      - file: {{ sls }} /srv/wiki/docroot
      - git: wiki.src cc.licenserdf repo
    - require_in:
      - test: wiki completed


{{ sls }} symlink schema.rdf:
  file.symlink:
    - name: /srv/wiki/docroot/schema.rdf
    - target: rdf-meta/schema.rdf
    - require:
      - file: {{ sls }} /srv/wiki/docroot
      - git: wiki.src cc.licenserdf repo
    - require_in:
      - test: wiki completed
