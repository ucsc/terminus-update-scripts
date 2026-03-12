# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm install          # Install standard-version tooling (one-time setup)
npm run release      # Bump version, generate CHANGELOG, create git tag
```

There are no build, test, or lint commands — these are standalone bash scripts.

Before running scripts, make them executable:
```bash
chmod +x scripts/multiple-sites/*.sh
chmod +x scripts/single-site/*.sh
```

## Architecture

Bash script suite for automating WordPress site updates on Pantheon hosting via the Terminus CLI. Scripts implement a three-step deployment pipeline:

```
1. update-*-dev.sh      → Apply WP core + plugin + theme updates to dev
2. deploy-*-to-test.sh  → Promote dev → test
3. deploy-*-to-live.sh  → Promote test → live
```

Two parallel implementations in `scripts/single-site/` and `scripts/multiple-sites/` share this same pipeline. The multiple-sites variants loop over sites filtered by Pantheon org tags (`--tag=ur --tag=live`).

Each script sources `secrets.sh` from its own directory as the first step. These files are gitignored and must be created locally from the `.example` files:

- `scripts/single-site/secrets.sh` — defines `SITE_NAME` (and `WP_SEARCH`/`WP_REPLACE` for db-search-replace)
- `scripts/multiple-sites/secrets.sh` — defines `PANTHEON_ORG` (org UUID)

`db-search-replace.sh` (single-site only) runs WP-CLI `search-replace` on the live database. It runs in `--dry-run` mode by default — the flag must be removed manually to apply changes.

## Key Conventions

**Variable naming:** Uppercase for sourced/exported vars (`SITE_NAME`, `PANTHEON_ORG`), lowercase for derived locals (`SITE`, `PANTHEON_SITES`).

**Pantheon environment targeting:** `$SITE.dev`, `$SITE.test`, `$SITE.live`

**WordPress update sequence in dev scripts:**
1. `terminus connection:set $SITE.dev git`
2. `terminus upstream:updates:apply --accept-upstream --yes`
3. `terminus connection:set $SITE.dev sftp`
4. `terminus remote:wp $SITE.dev -- plugin update --all`
5. `terminus remote:wp $SITE.dev -- theme update --all`
6. `terminus env:commit $SITE.dev --note="plugin and theme updates"`
7. `terminus env:clear-cache $SITE.dev`

**Multiple-sites loop pattern:**
```bash
PANTHEON_SITES="$(terminus org:site:list -n ${PANTHEON_ORG} --tag=ur --tag=live --format=list --field=Name)"
while read -r PANTHEON_SITE_NAME; do
    # process $PANTHEON_SITE_NAME
done <<< "$PANTHEON_SITES"
```

**Deployment flag:** Use `--note` (not `--message`) with `terminus env:deploy`.
