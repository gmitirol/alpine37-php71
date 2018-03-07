#!/bin/sh

set -e;

usage () {
    echo 'Usage: setup-gitlab-token-auth.sh [-u user] <clear|token> <gitlab-host>';

    exit 64;
}

while getopts 'u:' opt; do
    case $opt in
        u)
            USER=${OPTARG} ;;
        *)
            usage ;;
    esac
done
shift $((OPTIND-1))

TOKEN="$1";
GITLAB_HOST="$2";

if [ -z "$TOKEN" ] || [ -z "$GITLAB_HOST" ]; then
    usage;
fi;

if [ -z "$USER" ]; then
    USER='gitlab-ci-token';
fi

# clear old URL SSH to HTTP rewrites
OLDENTRIES=$(git config --global --get-regexp 'url\.https://.*:.*\.insteadof' | awk '{print $1}');
for ENTRY in $OLDENTRIES; do
    git config --global --unset "$ENTRY";
done;
composer config -q -g --unset "http-basic.$GITLAB_HOST";

# replace git SSH URLs for GitLab with HTTPS
if [ "$TOKEN" != 'clear' ] ; then
    git config --global url."https://$USER:$TOKEN@$GITLAB_HOST/".insteadOf "git@$GITLAB_HOST:";
    composer config -q -g -- "http-basic.$GITLAB_HOST" "$USER" "$TOKEN";
fi;
