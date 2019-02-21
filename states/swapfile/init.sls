{% set SWAPSIZE = salt["pillar.get"]("linux:swapsize", 0) -%}
{% if SWAPSIZE > 0 -%}


{{ sls }} create swapfile:
  cmd.run:
    - name: dd if=/dev/zero of=/swapfile bs=1024 count={{ SWAPSIZE }}M
    - unless:
      - test -f /swapfile


{{ sls }} swapfile permissions:
  file.managed:
    - name: /swapfile
    - mode: '0600'
    - replace: False
    - require:
      - cmd: {{ sls }} create swapfile


{{ sls }} activate swapfile:
  cmd.run:
    - name: mkswap /swapfile && swapon -a
    - unless:
      - file /swapfile 2>&1 | grep -q 'Linux/i386 swap'
    - require:
      - file: {{ sls }} swapfile permissions


{{ sls }} mount:
  mount.swap:
    - name: /swapfile
    - persist: True
    - require:
      - cmd: {{ sls }} activate swapfile


{% endif -%}
