This is a container that does WordPress and Docker _the right way._

## What's wrong with WordPress's Docker image?

The container shipped by WordPress copies over the contents of `/usr/src/wordpress` to `/var/www/html` when the container is first created, but only if no content already exists in `/var/www/html`. This means that if you've already deployed the container and have a persistent volume mounted at that location, you can upgrade your container from `4.7.4` to `4.8.1`, and although it claims to be `4.8.1`, nothing happens. You're still running `4.7.4`. If you want to upgrade, you have to do it manually, and if you're doing it manually, what's the point of upgrading the container?

## What's different about this image?

1. WordPress core and Wordpress content are separate
2. WordPress is installed as a submodule at build time, so we're always pulling from their repository (and not copying it needlessly)
3. WordPress knows how to operate with content in a different directory
4. WordPress knows how to operate as a submodule

This means that you can initialize your container, build your site, deploy it, and when WordPress releases a new version, simply _upgrade the image_ of your container and re-launch it. 

## Deployment Instructions

See [INSTALL.md](INSTALL.md) for installation instructions.

## Working With This Repository

When a new version of WordPress is released, change into `site/wordpress` and run the following:

```
git submodule update --remote
git fetch --tags
git checkout <new version>
cd ..
git add .
git commit -m 'update to new version'
```

