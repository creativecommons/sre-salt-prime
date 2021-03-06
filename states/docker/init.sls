# https://docs.docker.com/install/linux/docker-ce/debian/
{%- set os = grains['oscodename'] %}


{{ sls }} /srv/docker:
  file.directory:
    - name: /srv/docker
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} /var/lib/docker symlink:
  file.symlink:
    - name: /var/lib/docker
    - target: /srv/docker
    - force: True
    - require:
      - file: {{ sls }} /srv/docker


{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - gnupg2
      - python-apt
      - software-properties-common
    - require:
      - file: {{ sls }} /var/lib/docker symlink


{{ sls }} Docker CE Repository:
  pkgrepo.managed:
    - name: deb https://download.docker.com/linux/debian {{ os }} stable
    - file: /etc/apt/sources.list.d/docker-ce.list
    - key_url: https://download.docker.com/linux/debian/gpg
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
      - file: {{ sls }} manage Docker CE Repository file mode


{{ sls }} manage Docker CE Repository file mode:
  file.managed:
    - name: /etc/apt/sources.list.d/docker-ce.list
    - mode: '0444'
    - replace: False


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - containerd.io
      - docker-ce
      - docker-ce-cli
    - require:
      - file: {{ sls }} manage Docker CE Repository file mode
