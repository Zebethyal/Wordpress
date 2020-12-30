This is a container that does Wordpress _the right way._

I made a [YouTube video](https://www.youtube.com/watch?v=c5c9yVtQGbU) about how to use this.

## What's wrong with Wordpress's Docker image?

The container shipped by Wordpress copies over the contents of `/usr/src/wordpress` to `/var/www/html` when the container is first created, but only if no content already exists in `/var/www/html`. This means that if you've already deployed the container and have a persistent volume mounted at that location, you can upgrade your container inage from one version to the next, and although it claims to be an updated version, nothing happens. You're still running the original version because the entire contents of Wordpress were copied.

If you want to upgrade, you have to do it manually from within Wordpress, and if you're doing it manually, what's the point of upgrading the container?

## What's different about this image?

1. Wordpress core and Wordpress content are separate
2. Wordpress is installed as a submodule at build time, so we're always pulling from their repository (and not copying it needlessly)
3. Wordpress knows how to operate with content in a different directory
4. Wordpress knows how to operate as a submodule

This means that you can initialize your container, build your site, deploy it, and when Wordpress releases a new version, simply _upgrade the image_ of your container and re-launch it.

## Deployment Instructions

See [INSTALL.md](INSTALL.md) for instructions on how to deploy Wordpress using the image on Docker Hub

## Building Your Own Container

If you use custom PHP modules or other applications that aren't in the default Dockerfile, you'll be building your own containers. I recommend that you do this in a branch or with an alternate Dockerfile so that you don't pollute the main Dockerfile and can still `git pull` to bring down future changes without manually merging conflicts.

If this is your first time working with this repository, run `git submodule update --remote` before continuing. This will initialize the submodule content for Polyverse and Wordpress.

### Polyscripting 

If you're building the Polyscripting container, initialize the `pswp` content:

```
cd pswp
git pull
cd ..
git add .
git commit -m 'update polyscripting'
```

### Wordpress

When a new version of Wordpress is released, change into `site/wordpress` and run the following:

```
git fetch --tags
git checkout <new version>
cd ..
git add .
git commit -m 'update to new version'
```

Build a new image and push it to your container registry, and you're ready to update. Easy peasy.

