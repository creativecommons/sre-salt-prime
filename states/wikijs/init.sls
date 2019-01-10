{% set VERSION = pillar.wikijs.version -%}

{% set WIKI_DIR = "/srv/wikijs-{}".format(VERSION) -%}
{% set ARCHIVE_URL = "https://github.com/Requarks/wiki/releases/download" -%}


{{ sls }} {{ WIKI_DIR }} directory:
  file.directory:
    - name: {{ WIKI_DIR }}


{{ sls }} extract build archive:
  archive.extracted:
    - name: {{ WIKI_DIR }}
    - source: {{ ARCHIVE_URL }}/v{{ VERSION }}/wiki-js.tar.gz
    - source_hash: {{ pillar.wikijs.build_hash }}
    - trim_output: 25
    - enforce_toplevel: False
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory
    - unless:
      - test -d {{ WIKI_DIR }}/assets


{{ sls }} extract dependencies archive:
  archive.extracted:
    - name: {{ WIKI_DIR }}
    - source: {{ ARCHIVE_URL }}/v{{ VERSION }}/node_modules.tar.gz
    - source_hash: {{ pillar.wikijs.dependencies_hash }}
    - trim_output: 25
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory
    - unless:
      - test -d {{ WIKI_DIR }}/node_modules


{{ sls }} config file:
  file.managed:
    - name: {{ WIKI_DIR }}/config.yml
    - source: salt://wikijs/files/config.yml
    - template: jinja
    - mode: '0444'
    - require:
      - file: {{ sls }} {{ WIKI_DIR }} directory



{{ sls }} symlink pmwiki dir:
  file.symlink:
    - name: /srv/wikijs
    - target: wikijs-{{ VERSION }}
    - force: True
    - require:
      - archive: {{ sls }} extract build archive
      - archive: {{ sls }} extract dependencies archive
      - file: {{ sls }} config file
