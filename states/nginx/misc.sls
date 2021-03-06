include:
  - nginx


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git


{%- for repo in ("faq", "mp") %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: /srv/{{ repo }}
    - rev: {{ pillar.git_branch }}
    - branch: {{ pillar.git_branch }}
    - fetch_tags: False
    - require:
      - pkg: {{ sls }} installed packages
{%- endfor %}


{{ sls }} faq docroot symlink:
  file.symlink:
    - name: /var/www/html/faq
    - target: /srv/faq/faq
    - require:
      - git: {{ sls }} faq repo
      - pkg: nginx installed packages


{{ sls }} platform directory:
  file.directory:
    - name: /var/www/html/platform
    - makedirs: True
    - require:
      - git: {{ sls }} mp repo
      - pkg: nginx installed packages


{{ sls }} mp index symlink:
  file.symlink:
    - name: /var/www/html/platform/toolkit
    - target: /srv/mp/docs
    - require:
      - file: {{ sls }} platform directory
