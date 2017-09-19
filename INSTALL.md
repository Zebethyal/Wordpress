## TL;DR

Start a container with the following configuration:

1. Set the following variables:
    - WORDPRESS_DB_HOST
    - WORDPRESS_DB_PASSWORD_FILE (or WORDPRESS_DB_PASSWORD if you have no choice)
    - WORDPRESS_DB_NAME
    - WORDPRESS_DB_USER
    - WORDPRESS_URL
2. Mount a persistent volume at `/var/www/html/shared`

This could look something like:
```
docker run -d -v wp-data:/var/www/html/shared -p 8080:80 \
-e WORDPRESS_DB_HOST='db.example.com' -e WORDPRESS_DB_USER='wp_user' \
-e WORDPRESS_DB_PASSWORD='useRancherSecretsInstead' \
-e WORDPRESS_DB_NAME='wordpress' -e WORDPRESS_URL='https://www.example.com' \
monachus/docker-wordpress:4.8.1
```

## Detailed Version

Because Wordpress is running in a subdirectory of the document root, `wp-config.php` contains additional configuration that tells it where to find its various directories:

```
define('WP_HOME', 'https://www.example.com');
define('WP_SITEURL', 'https://www.example.com/wordpress');
define('WP_CONTENT_DIR', '/var/www/html/shared/wp-content/');
define('WP_CONTENT_URL', 'https://www.example.com/wp-content');
define('WP_PLUGIN_DIR', '/var/www/html/shared/wp-content/plugins/');
define('WP_PLUGIN_URL', 'https://www.example.com/wp-content/plugins');
```

These are built dynamically from the environment variable `WORDPRESS_URL`, which should contain the full URL for your site (including `http://` or `https://` but with _no trailing slash._)

This is in addition to the [other variables](https://hub.docker.com/_/wordpress/) that you can provide to Wordpress, which should be at least:

- WORDPRESS_DB_HOST
- WORDPRESS_DB_PASSWORD_FILE
- WORDPRESS_DB_NAME
- WORDPRESS_DB_USER

You'll see that I've specified `WORDPRESS_DB_PASSWORD_FILE` instead of `WORDPRESS_DB_PASSWORD`. This is because putting passwords into environment variables is a terrible practice.

_Don't do it._

Use a platform that lets you deploy secrets safely, such as [Rancher](https://www.rancher.com) or Kubernetes. If you deploy this container under Rancher, you can mount the database password at `/run/secrets/db_pass`, and you can set this as `WORDPRESS_DB_PASSWORD_FILE`. The init script for the container will read the contents of this file and place it in the appropriate location in the config.

The Compose file below is for an environment running Rancher with Rancher NFS and Rancher Secrets. Because you're running Rancher, you've already launched a service called `mariadb` in a stack called `db`, because with Rancher, there's no need to launch another database container for every service. This means that your database is reachable at the hostname of `mariadb.db`.

```
version: '2'
volumes:
  wp-data:
    external: true
    driver: rancher-nfs
services:
  www:
    image: monachus/docker-wordpress:4.8.1
    environment:
      WORDPRESS_DB_HOST: mariadb.db
      WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_pass
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_URL: https://www.example.co,
    volumes:
    - wp-data:/var/www/html/shared
    secrets:
    - mode: 440
      uid: '0'
      gid: '0'
      source: wordpress-db-pass-v1
      target: db_pass
secrets:
  wordpress-db-
  pass-v1:
    external: 'true'
```
