#!/bin/bash
# Import ITS UUID environment variable PANTHEON_ORG
source secrets.sh

# Stash list of UR sites in ITS
PANTHEON_SITES="$(terminus org:site:list -n ${PANTHEON_ORG} --tag=ur --tag=live --format=list --field=Name)"

# Loop through each site in the list
while read -r PANTHEON_SITE_NAME; do
    # Deploy
    echo "Deploying to $PANTHEON_SITE_NAME LIVE environment"
    terminus env:deploy $PANTHEON_SITE_NAME.live --note="plugin and theme  updates"
    
    # Clear cache
    echo "Clearing caches on $PANTHEON_SITE_NAME LIVE environment"
    terminus env:clear-cache $PANTHEON_SITE_NAME.live
    
    # Open each Live site
    echo "Firing up the $PANTHEON_SITE_NAME LIVE environment for review"
    terminus env:view $PANTHEON_SITE_NAME.live
done <<< "$PANTHEON_SITES"