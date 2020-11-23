{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set THEMES = "{}/themes".format(WP_CONTENT) -%}


{{ sls }} install pressbooks-book theme from zip:
  archive.extracted:
    - name: {{ THEMES }}
    - source: https://github.com/pressbooks/pressbooks-book/releases/download/2.2.1/pressbooks-book-2.2.1.zip
    - source_hash: 314cf15e6660ce80f27dfd2972532c0aea731a73a00830aa807178ec59bf8d6f
    - user: composer
    - group: webdev
    - require:
      - file: wordpress dir wp-content/themes
      - group: user.webdevs webdev group
      - user: php_cc.composer user
