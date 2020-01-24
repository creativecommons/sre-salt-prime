{%- for mount in pillar.mounts -%}
{%- set label = mount.file.replace("/", "-").strip("-") %}
{{ sls }} format {{ mount.spec }} as {{ mount.type }}:
  blockdev.formatted:
    - name: {{ mount.spec }}
    - fs_type: {{ mount.type }}


{{ sls }} label {{ mount.spec }} as {{ label }}:
  cmd.run:
    - name: e2label {{ mount.spec }} {{ label }}
    - onchanges:
      - blockdev: {{ sls }} format {{ mount.spec }} as {{ mount.type }}


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
      - blockdev: {{ sls }} format {{ mount.spec }} as {{ mount.type }}
      - cmd: {{ sls }} label {{ mount.spec }} as {{ label }}
{% endfor -%}
