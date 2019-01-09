{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - vim-nox


{{ sls }} set vim-nox as default editor:
  alternatives.set:
    - name: editor
    - path: /usr/bin/vim.nox
    - require:
      - pkg: {{ sls }} installed packages
