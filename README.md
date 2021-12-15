# Terminus Update Scripts

[![Terminus v1.x Compatible](https://img.shields.io/badge/terminus-v1.x-green.svg)](https://github.com/pantheon-systems/terminus-secrets-plugin/tree/1.x)

A set of `bash` scripts for "mass updating" sites on Pantheon using Terminus. These scripts are tooled for WordPress sites but can easily be repurposed for Drupal sites.  While there is a [Terminus Mass Update](https://github.com/pantheon-systems/terminus-mass-update) plugin, these scripts rely solely on base terminus commands; no additional plugins necessary. However, these scripts require setting  `ENVIRONMENT_VARIABLES` to store "secrets". I chose to put them in a local file that is not included in this repository. You may view a reference to it in the scripts. Directions for setting the environment variables are provided below.

## Reqiurements

- requirement: [terminus](https://pantheon.io/docs/terminus)  
- optional: [Node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) for installing a local version of [standard-version](https://github.com/conventional-changelog/standard-version)  
`npm install`

## The scripts

There are two sets of scripts in this repo, a set for updating multiple sites and a set for updating a single site. Each set of scripts consists of three scripts, each script addressing either the `dev`, `test` or `live` Pantheon Environments.

The following is a list of the scripts included and a brief description of each does. These scripts should generally be run in the order listed below:

1. **Update `dev`** `update-site-dev.sh` or `update-sites-dev.sh`  
  **Update core `<site>.<dev>`:**  
-- check whether WordPress core updates are available.  
-- set connection of all sites to `git` mode  
-- apply upstream updates  
-- reset connection of all sites to `sftp` mode  
-- clear all caches  
  **Apply WordPress theme and plugin updates:**  
-- update any plugins that need updating  
-- update any themes that need updating  
-- commit updates to the environment with a message  
-- clear caches in the `<site>.<dev>` environment  
-- open all `<site>.<dev>` environments in browser tabs for review
2. **Deploy from `<site>.<dev>` to `<site>.<test>`:** `deploy-site-to-test.sh` or `deploy-sites-to-test.sh`  
-- deploy sites to `<site>.<test>` with commit message  
-- clear all caches  
-- open all `<site>.<test>` environments in browser tabs for review

3. `deploy-to-live.sh`  
Does exactly the same tha **Script 2** does, except deploys from `<site>.<test>` to `<site>.<live>`.

## Set environment variables

I use a local script named `secrets.sh` placed in the same directory as the scripts. This is where the environment variables are set. To do similar, create a new file in each of the script directories:

```bash
touch /my-scripts-location/multiple-sites/secrets.sh

touch /my-scripts-location/single-site/secrets.sh
```

### Multiple sites

The `PANTHEON_ORG` **environment variable** used for updating multiple sites. Into your multiple-sites `secrets.sh` script, paste the following, using your own `ORG UUID`:

```bash
#!/bin/bash
# Stash ORG UUID
export PANTHEON_ORG="5234...9de8"
```

### Single site

The `SITE_NAME` **environment variable** is used for updating single sites. Into your single-site `secrets.sh` script, paste the following, using any portion of your single site's name:

```bash
#!/bin/bash
# Stash site name
export SITE_NAME="my-site-name"
```

### Make scripts executable

```bash
sudo chmod +x /my-scripts-location/multiple-sites/secrets.sh

sudo chmod +x /my-scripts-location/single-site/secrets.sh
```

## Run scripts

Once the environment variables are set, the scripts should be run in the order described above.

```bash
# note: let each script complete before running the next
user@machine:~$ ./update-sites-to-dev.sh

user@machine:~$ ./deploy-sites-to-test.sh

user@machine:~$ ./deploy-sites-to-live.sh
```
