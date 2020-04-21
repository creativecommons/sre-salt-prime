include:
  - ccengine.docroot
  - ccengine.env
  - ccengine.src
  - ccengine.transifex


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
      - pipenv
      - python-cssselect
      - python-flup
      - python-librdf
      - python-pip
      - virtualenv


{{ sls }} /srv/ccengine:
  file.directory:
    - name: /srv/ccengine
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} completed:
  test.nop:
    - require:
      - cmd: ccengine.transifex Compile Machine Object translation files
      - file: ccengine.transifex Translation stats symlink
