#!/bin/bash
#
# use the command line interface to install pushnotifications package.
# this script is in blue because it need blue whisk.properties.
#

: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH must be set and non-empty"}
AUTH_KEY=$WHISK_SYSTEM_AUTH

SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
CATALOG_HOME=$SCRIPTDIR
source "$CATALOG_HOME/util.sh"

dir=pushnotifications
git clone https://github.com/AnanthaKrish/wsk-pkg-pushnotifications.git "$dir"

if [ -f installPushpackage.sh ] ; then
    rm installPushpackage.sh
fi
cp $CATALOG_HOME/pushnotifications/installPushpackage.sh $CATALOG_HOME

./installPushpackage.sh

waitForAll

echo pushnotifications package ERRORS = $ERRORS
exit $ERRORS