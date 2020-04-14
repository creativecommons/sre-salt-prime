include:
  - ccengine


{{ sls }} /srv/ccengine/docroot:
  file.directory:
    - name: /srv/ccengine/docroot
    - require:
      - file: ccengine /srv/ccengine


{%- for dir in ["icons", "images", "includes", "legalcode"] %}


{{ sls }} symlink {{ dir }}:
  file.symlink:
    - name: /srv/ccengine/docroot/{{ dir }}
    - target: /srv/ccengine/src/creativecommons.org/docroot/{{ dir }}
    - require:
      - file: {{ sls }} /srv/ccengine/docroot
      - git: ccengine.src creativecommons.org repo
    - require_in:
      - test: ccengine completed
{%- endfor %}


{{ sls }} dir ns:
  file.directory:
    - name: /srv/ccengine/docroot/ns
    - require:
      - file: {{ sls }} /srv/ccengine/docroot


{{ sls }} symlink ns.html:
  file.symlink:
    - name: /srv/ccengine/docroot/ns/index.html
    - target: ../rdf-meta/ns.html
    - require:
      - file: {{ sls }} dir ns
      - git: ccengine.src cc.licenserdf repo
    - require_in:
      - test: ccengine completed


{{ sls }} symlink rdf-licenses:
  file.symlink:
    - name: /srv/ccengine/docroot/rdf-licenses
    - target: /srv/ccengine/src/cc.licenserdf/cc/licenserdf/licenses
    - require:
      - file: {{ sls }} /srv/ccengine/docroot
      - git: ccengine.src cc.licenserdf repo
    - require_in:
      - test: ccengine completed


{{ sls }} symlink rdf-meta:
  file.symlink:
    - name: /srv/ccengine/docroot/rdf-meta
    - target: /srv/ccengine/src/cc.licenserdf/cc/licenserdf/rdf
    - require:
      - file: {{ sls }} /srv/ccengine/docroot
      - git: ccengine.src cc.licenserdf repo
    - require_in:
      - test: ccengine completed


{{ sls }} symlink schema.rdf:
  file.symlink:
    - name: /srv/ccengine/docroot/schema.rdf
    - target: rdf-meta/schema.rdf
    - require:
      - file: {{ sls }} /srv/ccengine/docroot
      - git: ccengine.src cc.licenserdf repo
    - require_in:
      - test: ccengine completed
