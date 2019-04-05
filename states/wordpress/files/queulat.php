<?php
/**
 * Plugin Name: Queulat Loader
 * Description: Load Queulat mu-plugin
 */

// Load Composer autoloader (ABSPATH it's the path to wp-load.php).
require_once ABSPATH .'/../vendor/autoload.php';

// Load Queulat main file.
require_once __DIR__ .'/queulat/queulat.php';
