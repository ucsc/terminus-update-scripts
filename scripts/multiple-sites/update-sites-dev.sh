#!/bin/bash
# Export site name as environment variable PANTHEON_ORG:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file 
source secrets.sh

# Stash list of sites
# uses "--tag=ur" and "--tag=live" to filter for UR C&M sites, and "--field=Name" to grab the names
PANTHEON_SITES="$(terminus org:site:list -n ${PANTHEON_ORG} --tag=ur --tag=live --format=list --field=Name)"

# Loop through each site in the ITS list
while read -r PANTHEON_SITE_NAME; do 
  # Get the status of the upstream
  echo "Checking $PANTHEON_SITE_NAME"

  # Begin updating core
  echo "Updating $PANTHEON_SITE_NAME"

  # Set connection to git mode
  echo "Setting environment to git mode"
  terminus connection:set $PANTHEON_SITE_NAME.dev git

  # Apply upstream updates
  echo "Applying upstream updates"
  terminus upstream:updates:apply --accept-upstream --yes -- $PANTHEON_SITE_NAME.dev

  # Reset to sftp mode
  echo "Resetting connection to sftp"
  terminus connection:set $PANTHEON_SITE_NAME.dev sftp

  # Clear cache
  echo "Clearing caches"
  terminus env:clear-cache $PANTHEON_SITE_NAME.dev

  # Begin updating plugins and themes
  # Update all plugins
  echo "Updating plugins on $PANTHEON_SITE_NAME"
  terminus remote:wp $PANTHEON_SITE_NAME.dev -- plugin update --all
  
  # Update all themes
  echo "Updating themes on $PANTHEON_SITE_NAME"
  terminus remote:wp $PANTHEON_SITE_NAME.dev -- theme update --all
  
  # Commit changes
  echo "Committing updates on $PANTHEON_SITE_NAME"
  terminus env:commit $PANTHEON_SITE_NAME.dev --message="plugin and theme  updates"
  
  # Clear cache
  echo "Clearing caches on $PANTHEON_SITE_NAME"
  terminus env:clear-cache $PANTHEON_SITE_NAME.dev
  
  # Open Dev site
  echo "Firing up the dev environment on $PANTHEON_SITE_NAME"
  terminus env:view $PANTHEON_SITE_NAME.dev  
done <<< "$PANTHEON_SITES"