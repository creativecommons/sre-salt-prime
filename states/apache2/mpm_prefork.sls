# https://httpd.apache.org/docs/2.4/misc/perf-tuning.html#hardware
#
# The WORKERS formula, below, results in the following worker configurations:
#                Memory    Memory
#   Instance     listed      real  Workers
#   ---------  --------  --------  -------
#   t3.nano     512 MiB   439 MiB        8
#   t3.micro   1024 MiB   945 MiB       29
#   t3.small   2048 MiB  1932 MiB       70
#   t3.medium  4096 MiB  3873 MiB      151
#
# To view real memory available, use the following command:
#   sudo salt \* grains.item saltenv=${USER} mem_total
{% set WORKERS = ((grains.mem_total - 256) / 24)|round|int -%}

# This should only match the first time Salt is run against the host
{{ sls }} initial MaxRequestWorkers:
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

{{ sls }} manage MaxRequestWorkers:
  file.replace:
    - name: /etc/apache2/mods-available/mpm_prefork.conf
    # The following pattern is a little weird. It uses a negative lookahead
    # assertion to prevent churn. Because negative lookahead assertion don't
    # consume any of string, it is followed by a one or more decimal digit
    # match
    - pattern: ^\s*MaxRequestWorkers\s+(?!{{ WORKERS }})\d+
    - repl: \tMaxRequestWorkers\t  {{ WORKERS }}
    - flags:
      - IGNORECASE
      - MULTILINE
    - require:
      - pkg: apache2 installed packages
    - watch_in:
      - service: apache2 service
