# Required command line pillar data:
#   tgt_loc: targeted Location
#
# Example invocation:
#   sudo salt-run state.orchestrate orch.tag_all_ebs_volumes \
#     pillar='{"tgt_loc":"us-east-2"}' saltenv=timidrobot test=
{%- import "orch/aws/jinja2.sls" as aws with context %}
{%- set LOC = pillar.tgt_loc %}


{%- for id in salt.boto_ec2.find_instances(region=LOC) %}
{%- set tags = dict() %}
{%- set tags_list = salt.boto_ec2.get_tags(instance_id=id, region=LOC) %}
{%- for pair in tags_list %}
{%- set __ = tags.update(pair) %}
{%- endfor %}
{%- set HST = tags["Name"].split("_")[0] %}
{%- set POD = tags["cc:pod"] %}
{%- set ident = [HST, POD, "ebs-tags"] %}
{%- set name = ident|join("_") %}
{{ name }}:
  boto_ec2.volumes_tagged:
    - region: {{ LOC }}
    - name: {{ name }}
    - tag_maps:
      - filters:
          attachment.instance_id: {{ id }}
        tags:
          Name: {{ name }}
          cc:pod: {{ POD }}
{{- aws.infra_dict("aws", "tags", HST, POD, indent=10) }}
{%- endfor %}
