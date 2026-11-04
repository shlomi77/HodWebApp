#!/bin/sh
# index.html is the whole app (HTML + CSS + JS, no build step).
# GitHub Pages serves the docs/ folder, so keep a copy there.
cd "$(dirname "$0")"
mkdir -p docs && cp index.html docs/index.html && touch docs/.nojekyll
echo "docs/index.html updated"
