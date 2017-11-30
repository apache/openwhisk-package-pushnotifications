#!/bin/bash

SCRIPTDIR=$(cd $(dirname "$0") && pwd)
HOMEDIR="$SCRIPTDIR/../../../"

if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then openssl aes-256-cbc -K $encrypted_ff5bbb6225c5_key -iv $encrypted_ff5bbb6225c5_iv -in tests/credentials.json.enc -out tests/credentials.json -d; fi

# clone utilties repo. in order to run scanCode.py
cd $HOMEDIR
git clone https://github.com/apache/incubator-openwhisk-utilities.git

# shallow clone OpenWhisk repo.
git clone --depth 1 https://github.com/apache/incubator-openwhisk.git openwhisk

cd openwhisk
if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then bash ./tools/travis/setup.sh; fi
