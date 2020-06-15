include:
  - apache2.wordpress_composer
{%- if not salt.pillar.get("apache2:sheltered", false) %}
  - letsencrypt
{%- endif %}
  - php_cc.apache2
  - wordpress
