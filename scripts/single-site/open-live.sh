#!/bin/bash
# Export site name as environment variable SITE_NAME:
# `export SITE_NAME="my-site-name"`
# This script uses a local `secrets.sh` file
source secrets.sh
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"
# Open Live site
echo "Firing up the $SITE LIVE environment for review"
terminus env:view $SITE.live