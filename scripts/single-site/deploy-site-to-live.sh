#!/bin/bash
# Export site name as environment variable SITE_NAME:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file
source secrets.sh

# Get site name
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"

# Deploy
echo "Deploying to $SITE LIVE environment"
terminus env:deploy $SITE.live --note="plugin and theme updates"

# Clear cache
echo "Clearing caches on $SITE LIVE environment"
terminus env:clear-cache $SITE.live

# Open Live site
echo "Firing up the $SITE LIVE environment for review"
terminus env:view $SITE.live