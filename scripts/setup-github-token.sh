#!/bin/sh

set -e;

GITHUB_TOKEN="$1";

if [ -z "$GITHUB_TOKEN" ]; then
    echo 'Usage: setup-github-token.sh <clear|oauthtoken>';
    exit 64;
fi;

# Github API Token (see https://github.com/settings/tokens)
if [ "$GITHUB_TOKEN" == "clear" ]; then
    composer config -g github-oauth.github.com --unset
else
    composer config -g github-oauth.github.com $GITHUB_TOKEN;
fi;
