{% for mount in pillar.mounts -%}
{{ sls }} format {{ mount.type }}:
  blockdev.formatted:
    - name: {{ mount.spec }}
    - fs_type: {{ mount.type }}


{{ sls }} mount {{ mount.file }}:
  mount.mounted:
    - name: {{ mount.file }}
    - device: {{ mount.spec }}
    - fstype: {{ mount.type }}
    - mkmnt: True
    - opts: {{ mount.opts }}
    - dump: {{ mount.freq }}
    - pass_num: {{ mount.pass }}
{% endfor -%}
