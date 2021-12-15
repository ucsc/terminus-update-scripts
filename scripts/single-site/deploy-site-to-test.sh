#!/bin/bash
# Export site name as environment variable SITE_NAME:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file
source secrets.sh

# Get site name
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"

# Deploy
echo "Deploying to $SITE TEST environment"
terminus env:deploy $SITE.test --note="plugin and theme updates"

# Clear cache
echo "Clearing caches on $SITE TEST environment"
terminus env:clear-cache $SITE.test

# Open Test site
echo "Firing up the $SITE TEST environment for review"
terminus env:view $SITE.test