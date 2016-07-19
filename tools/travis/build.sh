# Build script for Travis-CI.

SCRIPTDIR=$(cd $(dirname "$0") && pwd)
ROOTDIR="$SCRIPTDIR/../../openwhisk"

cd $ROOTDIR

cp $ROOTDIR/../tests/src/* $ROOTDIR/tests/src/packages/

tools/build/scanCode.py .

cd $ROOTDIR/ansible

ANSIBLE_CMD="ansible-playbook -i environments/travis"

$ANSIBLE_CMD setup.yml
$ANSIBLE_CMD prereq.yml
$ANSIBLE_CMD couchdb.yml
$ANSIBLE_CMD initdb.yml

cd $ROOTDIR

./gradlew distDocker

cd $ROOTDIR/ansible

$ANSIBLE_CMD wipe.yml
$ANSIBLE_CMD openwhisk.yml
$ANSIBLE_CMD postdeploy.yml

cd $ROOTDIR

VCAP_SERVICES_FILE="$(readlink -f $ROOTDIR/../tests/credentials.json)"

#update whisk.properties to add tests/credentials.json file to vcap.services.file, which is needed in tests
WHISKPROPS_FILE="$ROOTDIR/whisk.properties"
sed -i 's:^[ \t]*vcap.services.file[ \t]*=\([ \t]*.*\)$:vcap.services.file='$VCAP_SERVICES_FILE':'  $WHISKPROPS_FILE
cat whisk.properties

WSK_CLI=$ROOTDIR/bin/wsk
AUTH_KEY=$(cat $ROOTDIR/ansible/files/auth.whisk.system)
EDGE_HOST=$(grep '^edge.host=' $WHISKPROPS_FILE | cut -d'=' -f2) 

# Install the package
source $ROOTDIR/../install.sh $EDGE_HOST $AUTH_KEY $WSK_CLI

#Test only the test cases classes in tests/src (Openwhisk dependencies are needed)
X="./gradlew :tests:test "
for f in $(ls $ROOTDIR/../tests/src | sed -e 's/\..*$//'); do X="$X --tests \"packages.$f\""; done
eval $X
