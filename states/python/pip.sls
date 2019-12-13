{%- from "python/map.jinja" import py with context %}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - {{ py.pip_package }}
