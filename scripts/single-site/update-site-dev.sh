#!/bin/bash
# Export site name as environment variable SITE_NAME:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file
source secrets.sh

# Get site name
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"

# Get the status of the upstream
echo "Checking $SITE"

# Begin updating core
echo "Updating $SITE"

# Set connection to git mode
echo "Setting environment to git mode"
terminus connection:set $SITE.dev git

# Apply upstream updates
echo "Applying upstream updates"
terminus upstream:updates:apply --accept-upstream --yes -- $SITE.dev

# Reset to sftp mode
echo "Resetting connection to sftp"
terminus connection:set $SITE.dev sftp

# Clear cache
echo "Clearing caches"
terminus env:clear-cache $SITE.dev

# Begin updating plugins and themes
# Update all plugins
echo "Updating plugins on $SITE"
terminus remote:wp $SITE.dev -- plugin update --all

# Update all themes
echo "Updating themes on $SITE"
terminus remote:wp $SITE.dev -- theme update --all

# Commit changes
echo "Committing updates on $SITE"
terminus env:commit $SITE.dev --message="plugin and theme updates"

# Clear cache
echo "Clearing caches on $SITE"
terminus env:clear-cache $SITE.dev

# Open Dev site
echo "Firing up the dev environment on $SITE"
terminus env:view $SITE.dev  