{% for mount in pillar.mounts -%}
{% set label = mount.file.replace("/", "-").strip("-") -%}
{% set spec_short = mount.spec.split("/")[2] -%}
{% set spec_long = "/dev/{}".format(spec_short) -%}


{{ sls }} convience symlink:
  cmd.run:
    - name: |
        for n in /dev/nvme?n?
        do
          if nvme id-ctrl -v ${n} | grep -q '^0000:.*{{ spec_short }}'
          then
            ln -s ${n} {{ spec_long }}
          else
            continue
          fi
        done
    - require:
      - pkg: common installed packages
    - unless:
      - test -e {{ spec_long }}


{{ sls }} format {{ spec_long }} as {{ mount.type }}:
  blockdev.formatted:
    - name: {{ spec_long }}
    - fs_type: {{ mount.type }}
    - require:
      - {{ sls }} convience symlink


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
      - blockdev: {{ sls }} format {{ spec_long }} as {{ mount.type }}
      - cmd: {{ sls }} label {{ spec_long }} as {{ label }}


{%- endfor %}
