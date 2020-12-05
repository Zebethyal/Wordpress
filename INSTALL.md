# Installation Instructions

The instructions below are for running the container under Kubernetes.

## TL;DR

Deploy a workload with the following configuration:

1. Variables:
    - WORDPRESS_DB_HOST
    - WORDPRESS_DB_PASSWORD (or WORDPRESS_DB_PASSWORD_FILE)
    - WORDPRESS_DB_NAME
    - WORDPRESS_DB_USER
    - WORDPRESS_URL
2. Mount a persistent volume at `/var/www/html/shared`

## Detailed Version

Because Wordpress is running in a subdirectory of the document root, `wp-config.php` contains additional configuration that tells it where to find its various directories:

```
define('WP_HOME', 'https://www.example.com');
define('WP_SITEURL', 'https://www.example.com/wordpress');
define('WP_CONTENT_DIR', '/var/www/html/shared/wp-content/');
define('WP_CONTENT_URL', 'https://www.example.com/wp-content');
define('WP_PLUGIN_URL', 'https://www.example.com/wp-content/plugins');
```

These are built dynamically from the environment variable `WORDPRESS_URL`, which should contain the full URL for your site (including `http://` or `https://` but with _no trailing slash._)

This is in addition to the [other variables](https://hub.docker.com/_/wordpress/) that you can provide to Wordpress, which should be at least:

- WORDPRESS_DB_HOST
- WORDPRESS_DB_PASSWORD_FILE or WORDPRESS_DB_PASSWORD (see below)
- WORDPRESS_DB_NAME
- WORDPRESS_DB_USER

### Using WORDPRESS_DB_PASSWORD or WORDPRESS_DB_PASSWORD_FILE

Create a Secret that contains `WORDPRESS_DB_PASSWORD` and attach that to your Pod at runtime. Kubernetes will safely handle the environment variables.

You can also mount the Secret as a volume instead of an environment variable and point `WORDPRESS_DB_PASSWORD_FILE` to its location. The init script for the container will read the contents of this file and place it in the appropriate location in the config.
