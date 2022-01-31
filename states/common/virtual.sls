{% if salt["grains.get"]("virtual") == "kvm" -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - virt-what


{%- endif %}
