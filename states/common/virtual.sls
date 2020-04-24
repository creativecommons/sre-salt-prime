{# AMI_ID is also checked to mitigate:
  virtual grain on debian buster is "physical" instead of "kvm" - Issue #56885
  https://github.com/saltstack/salt/issues/56885
#}
{% set VIRTUAL = salt["grains.get"]("virtual") -%}
{% set AMI_ID = salt["grains.get"]("meta-data:ami-id") -%}
{% if AMI_ID or VIRTUAL == "kvm" -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - virt-what


{%- endif %}
