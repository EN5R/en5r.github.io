#!/bin/bash
# Runs at the start of every Claude Code on the web session.
# This repo is a GitHub Pages site with no build tooling today, so there is
# nothing to install. The checks below are guards: if a manifest is ever added
# (package.json, Gemfile, requirements.txt), its dependencies get installed
# automatically without anyone having to touch this file again.
set -euo pipefail

# Only do work in the remote (web) environment; local runs stay untouched.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}"

installed=0

if [ -f package.json ]; then
  echo "==> package.json found, running npm install"
  npm install --no-audit --no-fund
  installed=1
fi

if [ -f Gemfile ]; then
  echo "==> Gemfile found, running bundle install"
  bundle config set --local path vendor/bundle
  bundle install --jobs 4
  installed=1
fi

if [ -f requirements.txt ]; then
  echo "==> requirements.txt found, running pip install"
  pip install --quiet -r requirements.txt
  installed=1
fi

if [ "$installed" -eq 0 ]; then
  echo "==> No dependency manifest found - static site, nothing to install."
fi

echo "==> Session setup complete."
