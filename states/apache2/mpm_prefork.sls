# https://httpd.apache.org/docs/2.4/misc/perf-tuning.html#hardware
#
# The below results in the following worker configurations:
#      Instance        Memory     Workers
#   --------------    --------    -------
#   t3.nano list       512 MiB         16
#   t3.nano real       470 MiB         16
#   t3.micro list     1024 MiB         48
#   t3.micro real      968 MiB         48
#   t3.small list     2048 MiB        112
#   t3.small real     1959 MiB        112
#   t3.medium list    4096 MiB        240
#   t3.medium real    3895 MiB        224
#   m5a.large list    8192 MiB        496
{% set WORKERS = (((grains.mem_total - 256) / 256)|round * 16)|int -%}
{{ sls }} disable TCPKeepAlive:
  file.replace:
    - name: /etc/apache2/mods-available/mpm_prefork.conf
    - pattern: ^\s*MaxRequestWorkers\s+150\s*$
    - repl: >-
        \t# Managed by SaltStack: {{ sls }}\n
        \t#MaxRequestWorkers\t  150\n
        \tMaxRequestWorkers\t  {{ WORKERS }}\n
    - flags:
      - IGNORECASE
      - MULTILINE
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
