#!/bin/bash
# Build script for Travis-CI.

SCRIPTDIR=$(cd $(dirname "$0") && pwd)
ROOTDIR="$SCRIPTDIR/../.."
WHISKDIR="$ROOTDIR/openwhisk"

cd $WHISKDIR

tools/build/scanCode.py $ROOTDIR

# No point to continue with PRs, since encryption is on
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then exit 0; fi

cd $WHISKDIR/ansible

ANSIBLE_CMD="ansible-playbook -i environments/local"

$ANSIBLE_CMD setup.yml
$ANSIBLE_CMD prereq.yml
$ANSIBLE_CMD couchdb.yml
$ANSIBLE_CMD initdb.yml
$ANSIBLE_CMD properties.yml

cd $WHISKDIR

TERM=dumb ./gradlew \
:common:scala:install \
:core:controller:install \
:core:invoker:install \
:tests:install \
:tools:admin:install \
distDocker

cd $WHISKDIR/ansible

$ANSIBLE_CMD wipe.yml
$ANSIBLE_CMD openwhisk.yml

cd $WHISKDIR

VCAP_SERVICES_FILE="$(readlink -f $WHISKDIR/../tests/credentials.json)"

#update whisk.properties to add tests/credentials.json file to vcap.services.file, which is needed in tests
WHISKPROPS_FILE="$WHISKDIR/whisk.properties"
sed -i 's:^[ \t]*vcap.services.file[ \t]*=\([ \t]*.*\)$:vcap.services.file='$VCAP_SERVICES_FILE':'  $WHISKPROPS_FILE
cat whisk.properties

WSK_CLI=$WHISKDIR/bin/wsk
AUTH_KEY=$(cat $WHISKDIR/ansible/files/auth.whisk.system)
EDGE_HOST=$(grep '^edge.host=' $WHISKPROPS_FILE | cut -d'=' -f2)

# Set Environment
export OPENWHISK_HOME=$WHISKDIR

# Install the package
source $ROOTDIR/packages/installCatalog.sh $AUTH_KEY $EDGE_HOST $WSK_CLI

# Test
cd $ROOTDIR
./gradlew :tests:test

