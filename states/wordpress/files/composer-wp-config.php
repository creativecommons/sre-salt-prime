<?php
/**
 * The base configuration for WordPress
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

if ( !defined('ABSPATH') ) {
    define('ABSPATH', dirname(__FILE__) . '/');
}
if($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'){
    $_SERVER['HTTPS']       = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}
/* PHP notice: Undefined index on $_SERVER superglobal
 * https://make.wordpress.org/cli/handbook/common-issues/#php-notice-undefined-index-on-_server-superglobal
 */
if ( defined( 'WP_CLI' ) && WP_CLI && ! isset( $_SERVER['SERVER_NAME'] ) ) {
    $_SERVER['SERVER_NAME'] = 'localhost';
}
define('WP_SITEURL',        'https://'.$_SERVER['SERVER_NAME']);
define('WP_HOME',           'https://'.$_SERVER['SERVER_NAME']);
define('WP_CONTENT_DIR',    dirname(__FILE__) . '/wp-content');
define('WP_CONTENT_URL',    WP_SITEURL . '/wp-content');

/* Database */
define('DB_NAME',       '{{ pillar.wordpress.db_name }}');
define('DB_USER',       '{{ pillar.wordpress.db_user }}');
define('DB_PASSWORD',   '{{ pillar.wordpress.db_password }}');
define('DB_HOST',       '{{ pillar.wordpress.db_host }}');
define('DB_CHARSET',    '{{ pillar.mysql.default_character_set }}');
define('DB_COLLATE',    '{{ pillar.mysql.default_collate }}');
$table_prefix  = '{{ salt.pillar.get("wordpress:table_prefix", "wp_") }}';

/* Authentication Unique Keys and Salts */
define('AUTH_KEY',         '{{ pillar.wordpress.auth_key }}');
define('SECURE_AUTH_KEY',  '{{ pillar.wordpress.secure_auth_key }}');
define('LOGGED_IN_KEY',    '{{ pillar.wordpress.logged_in_key }}');
define('NONCE_KEY',        '{{ pillar.wordpress.nonce_key }}');
define('AUTH_SALT',        '{{ pillar.wordpress.auth_salt }}');
define('SECURE_AUTH_SALT', '{{ pillar.wordpress.secure_auth_salt }}');
define('LOGGED_IN_SALT',   '{{ pillar.wordpress.logged_in_salt }}');
define('NONCE_SALT',       '{{ pillar.wordpress.nonce_salt }}');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', {{ pillar.wordpress.wp_debug }});

/* Multisite */
define('MULTISITE',             {{ pillar.wordpress.multisite }});
{%- if pillar.wordpress.multisite %}
define('WP_ALLOW_MULTISITE',    True);
define('SUBDOMAIN_INSTALL',     {{ pillar.wordpress.subdomain_install }});
define('DOMAIN_CURRENT_SITE',   '{{ pillar.wordpress.domain_current_site }}');
define('PATH_CURRENT_SITE',     '{{ pillar.wordpress.path_current_site }}');
define('SITE_ID_CURRENT_SITE',  {{ pillar.wordpress.site_id_current_site }});
define('BLOG_ID_CURRENT_SITE',  {{ pillar.wordpress.blog_id_current_site }});
define('SUNRISE',               '{{ pillar.wordpress.sunrise }}');
{%- endif %}

define('DISALLOW_FILE_EDIT', True);
#define('DISALLOW_FILE_MODS', True);

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
