include:
  - postgres.client


{{ sls }} append:
  file.append:
    - name: /etc/postgresql-common/user_clusters
    - text:
      - "# Managed by SaltStack: {{ sls }}"
{%- for cluster in pillar.postgres.user_clusters %}
      - "{{ "{0}  {1}  {2}  {3}  {4}".format(*cluster) }}"
{%- endfor %}
    - require:
      - pkg: postgresql-client-libs
