#!/bin/bash
# Import ITS UUID environment variable PANTHEON_ORG
# secrets.sh is not included in the git repo
source secrets.sh

# Stash list of UR sites in ITS
PANTHEON_SITES="$(terminus org:site:list -n ${PANTHEON_ORG} --tag=ur --tag=live --format=list --field=Name)"

# Loop through each site in the list
while read -r PANTHEON_SITE_NAME; do
    # Deploy
    echo "Deploying to $PANTHEON_SITE_NAME TEST environment"
    terminus env:deploy $PANTHEON_SITE_NAME.test --note="plugin and theme  updates"
    # Clear cache
    echo "Clearing caches on $PANTHEON_SITE_NAME TEST environment"
    terminus env:clear-cache $PANTHEON_SITE_NAME.test
    # Open Test site
    echo "Firing up the $PANTHEON_SITE_NAME TEST environment for review"
    terminus env:view $PANTHEON_SITE_NAME.test
done <<< "$PANTHEON_SITES"
# Magazine
# Deploy
echo "Deploying to $MAGAZINE TEST environment"
terminus env:deploy $MAGAZINE.test --message="plugin and theme updates"
# Clear cache
echo "Clearing caches on $MAGAZINE TEST environment"
terminus env:clear-cache $MAGAZINE.test
# Open Test site
echo "Firing up the $MAGAZINE TEST environment for review"
terminus env:view $MAGAZINE.test