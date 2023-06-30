#!/bin/bash
# Export site name as environment variable SITE_NAME:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file
source secrets.sh
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"
# Search and replace
echo "Searching $SITE LIVE database for $WP_SEARCH to replace with $WP_REPLACE"
terminus remote:wp --progress -- $SITE.live search-replace '$WP_SEARCH' '$WP_REPLACE' --dry-run