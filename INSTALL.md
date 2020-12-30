# Installation Instructions

The instructions below are for running the container under Kubernetes. The instructions are for a normal installation, with additional details that enable [Polyscripting](https://polyverse.com/products/polyscripting-wordpress-security/) at the end. Polyscripting will stop 0-day attacks against Wordpress and PHP and is worth considering for your environment.

For a set of sample Kustomize scripts that will deploy a standard and Polyscripted Wordpress environment, see [the resources for the YouTube video](https://gitlab.com/monachus/channel/-/tree/master/resources/2020.06). 

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

## Polyscripting Support

An alternate Dockerfile is present as `Dockerfile.pv` that enables Polyscripting support for Wordpress and PHP. This is also available in the container images with tags that end in `-pv`, like `v5.6.0-pv`.  

When Polyscripting is enabled, the Wordpress core and your content are copied from `/wordpress` to `/var/www/html` and scrambled. You can do anything that you would normally be able to do _except_ things that affect PHP content directly. You can create posts, upload images, and use the site normally. You cannot add or update themes or directly edit any PHP files.

Polyscripted containers take longer to start because they recompile everything at startup. Each container that you run will have its own unique scrambled implementation of PHP.

To enable Polyscripting: 

1. Change the mount point for your content to `/wordpress/shared`.
2. Add an additional variable of `POLYSCRIPTING_MODE=on` (or any value other than `off`). 

To disable Polyscripting:

1. Set `POLYSCRIPTING_MODE` to `off`
2. Restart the deployment with `kubectl rollout restart <deployment-name>`

To make changes to your site when running with Polyscripting:

1. Restart with Polyscripting disabled
2. Upload themes, plugins, or PHP content
3. Restart with Polyscripting enabled

If you have advanced skills in routing with Kubernetes, you could also run a restricted-access non-Polyscripted container with the same configuration (same database, same NFS volume for shared content), and after making updates there, restart the Polyscripted containers. When they restart, they'll copy the new content into /var/www/html and scramble it. This will prevent you from ever exposing non-Polyscripted containers to the Internet, even during updates.

