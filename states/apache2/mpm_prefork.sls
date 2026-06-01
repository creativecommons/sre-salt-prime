# https://httpd.apache.org/docs/2.4/misc/perf-tuning.html#hardware
#
# The WORKERS formula, below, results in the following worker configurations:
#                 Memory    Memory
#   Instance      listed      real  Workers
#   ---------   --------  --------  -------
#   t3.nano      512 MiB   439 MiB        8
#   t3.micro    1024 MiB   945 MiB       29
#   t3.small    2048 MiB  1932 MiB       70
#   t3.medium   4096 MiB  3873 MiB      151
#   r8a.medium  8192 MiB  7780 MiB      314
#
# To view real memory available, use the following command:
#   sudo salt \* grains.item saltenv=${USER} mem_total
{% set WORKERS = ((grains.mem_total - 256) / 24)|round|int -%}


{{ sls }} backup original mpm_prefork.conf:
  file.copy:
    - name: /etc/apache2/mods-available/mpm_prefork.conf.orig
    - source: /etc/apache2/mods-available/mpm_prefork.conf
    - force: False
    - preserve: True
    - require:
      - pkg: apache2 installed packages


{{ sls }} manage mpm_prefork.conf:
  file.managed:
    - name: /etc/apache2/mods-available/mpm_prefork.conf
    - source: salt://apache2/files/mpm_prefork.conf
    - mode: '0444'
    - template: jinja
    - defaults:
        WORKERS: {{ WORKERS }}
    - require:
      - file: {{ sls }} backup original mpm_prefork.conf 
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
