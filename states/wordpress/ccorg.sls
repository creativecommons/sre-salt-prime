{% set DOCROOT = pillar.wordpress.docroot -%}
{% set GIT = "/var/www/git" -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set THEMES = "{}/themes".format(WP_CONTENT) -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
    - require:
      - file: wordpress symlink wp-content


{{ sls }} {{ GIT }} directory:
  file.directory:
    - name: {{ GIT }}
    - mode: '2775'
    - group: webdev
    - require:
      - pkg: {{ sls }} installed packages


{%- for repo in ("new-creativecommons.org", "new-www-plugin") %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: {{ GIT }}/{{ repo }}
    - rev: {{ pillar.ccorg.branch }}
    - branch: {{ pillar.ccorg.branch }}
    - user: composer
    - fetch_tags: False
    - require:
      - file: {{ sls }} {{ GIT }} directory


{{ sls }} {{ repo }} permissions:
  file.directory:
    - name: {{ GIT }}/{{ repo }}
    - dir_mode: '2775'
    - file_mode: '0664'
    - group: webdev
    - recurse:
      - mode
      - group
    - require:
      - git: {{ sls }} {{ repo }} repo
{%- endfor %}


{#- new-creativecommons.org symlinks #}
{%- for target in ("favicon.ico", "icons", "images", "includes") %}


{{ sls }} symlink new-creativecommons.org {{ target }}:
  file.symlink:
    - name: {{ DOCROOT }}/{{ target }}
    - target: {{ GIT }}/new-creativecommons.org/docroot/{{ target }}
    - force: True
    - require:
      - file: {{ sls }} new-creativecommons.org permissions
{%- endfor %}


{#- new-www-plugin symlinks #}
{%- for target in ("cc-author", "cc-donate", "cc-program", "cc-resource",
                   "cc-taxonomies", "cc-widgets") %}


{{ sls }} symlink new-www-plugin {{ target }}:
  file.symlink:
    - name: {{ PLUGINS }}/{{ target }}
    - target: {{ GIT }}/new-www-plugin/{{ target }}
    - force: True
    - require:
      - file: {{ sls }} new-www-plugin permissions
{%- endfor %}
