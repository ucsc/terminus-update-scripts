# Copilot Instructions

## Project Overview

Bash script suite for automating WordPress site updates on [Pantheon](https://pantheon.io/) hosting via the [Terminus CLI](https://docs.pantheon.io/terminus). Scripts handle WordPress core, plugin, and theme updates across `dev → test → live` environments. Two modes: single-site and multiple-sites (batch).

## Commands

```bash
npm run release   # Bump version, generate CHANGELOG, create git tag (standard-version)
```

No build, test, or lint commands — these are standalone bash scripts.

## Architecture

Scripts follow a three-step deployment pipeline:

```
1. update-*-dev.sh       → Apply WP core + plugin + theme updates to dev environment
2. deploy-*-to-test.sh   → Promote dev → test
3. deploy-*-to-live.sh   → Promote test → live
```

Both `scripts/single-site/` and `scripts/multiple-sites/` implement this same pipeline. Multiple-sites scripts iterate over sites filtered by Pantheon org tags (`--tag=ur --tag=live`).

Each script sources `secrets.sh` from its own directory for environment variables. These files are excluded from git and must be created locally.

- `scripts/single-site/secrets.sh` — defines `SITE_NAME`
- `scripts/multiple-sites/secrets.sh` — defines `PANTHEON_ORG` (org UUID)

## Key Conventions

### Script structure

Every script follows this pattern:
```bash
#!/bin/bash
# Description comment
source secrets.sh           # Always first — loads env vars
SITE="$(terminus site:list --name=$SITE_NAME --format=list --field=Name)"
echo "Checking $SITE"       # Echo before each operation
terminus <command> ...
```

### Variable naming

- **Uppercase** for sourced/exported variables: `SITE_NAME`, `PANTHEON_ORG`, `PANTHEON_SITE_NAME`
- **Lowercase** for derived locals: `SITE`, `PANTHEON_SITES`

### Pantheon environment identifiers

Terminus targets environments as `$SITE.dev`, `$SITE.test`, `$SITE.live`.

### WordPress update sequence (within update scripts)

1. Switch to `git` connection mode (`terminus connection:set $SITE.dev git`)
2. Apply upstream updates (`terminus upstream:updates:apply`)
3. Switch back to `sftp` mode
4. Run WP-CLI via `terminus remote:wp $SITE.dev -- plugin update --all`
5. Commit SFTP changes (`terminus env:commit`)
6. Clear cache (`terminus env:clear-cache`)

### Multiple-sites loop pattern

```bash
PANTHEON_SITES="$(terminus org:site:list -n ${PANTHEON_ORG} --tag=ur --tag=live --format=list --field=Name)"
while read -r PANTHEON_SITE_NAME; do
    # process $PANTHEON_SITE_NAME
done <<< "$PANTHEON_SITES"
```

### Deployment note flag

Use `--note` (not `--message`) with `terminus env:deploy` for consistency.
