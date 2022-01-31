{% for mount in pillar.mounts -%}
{% set label = mount.file.replace("/", "-").strip("-") -%}
{% set spec_short = mount.spec.split("/")[2] -%}
{% set spec_long = "/dev/{}".format(spec_short) -%}


{{ sls }} add convience symlink:
  cmd.run:
    - name: |
        for n in /dev/nvme?n?
        do
          if nvme id-ctrl -v ${n} | grep -q '^0000:.*{{ spec_short }}'
          then
            ln -s ${n} {{ spec_long }}
          fi
        done
    - require:
      - pkg: common installed packages
    - unless:
      - test -h {{ spec_long }}


{{ sls }} format {{ spec_long }} as {{ mount.type }}:
  blockdev.formatted:
    - name: {{ spec_long }}
    - fs_type: {{ mount.type }}
    - require:
      - cmd: {{ sls }} add convience symlink
    - unless:
      # Use shell or ("||") so that this state only runs if all are false
      # (salstack unless means the state runs if any are false)
      - |
        test -d {{ mount.file }}/lost+found \
        || lsblk -n -oFSTYPE {{ spec_long }} | grep -q '^ext4'


{{ sls }} label {{ spec_long }} as {{ label }}:
  cmd.run:
    - name: e2label {{ spec_long }} {{ label }}
    - onchanges:
      - blockdev: {{ sls }} format {{ spec_long }} as {{ mount.type }}


{{ sls }} mount {{ mount.file }}:
  mount.mounted:
    - name: {{ mount.file }}
    - device: LABEL={{ label }}
    - fstype: {{ mount.type }}
    - mkmnt: True
    - opts: {{ mount.opts }}
    - dump: {{ mount.freq }}
    - pass_num: {{ mount.pass }}
    - match_on: name
    - require:
      - cmd: {{ sls }} add convience symlink
      - cmd: {{ sls }} label {{ spec_long }} as {{ label }}


{%- endfor %}
