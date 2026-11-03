#!/bin/sh
# Wrap app.html in a full HTML document so it opens directly in a browser.
cd "$(dirname "$0")"
{ printf '<!doctype html>\n<html lang="he" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n<style>body{margin:0}[hidden]{display:none!important}</style>\n'; cat app.html; printf '\n</html>\n'; } > index.html
mkdir -p docs && cp index.html docs/index.html  # GitHub Pages serves from /docs
