#!/usr/bin/env sh

set -e # exit on first failed commandset

installGems() {
  echo "Installing gems..."

  bundle install
  bundle update fastlane
  bundle update signet
}

androidSteps() {
  echo "========================================"
  echo "|       Android post-clone steps       |"
  echo "========================================"

  # set up key.properties
  echo $ANDROID_KEYSTORE | base64 --decode > /tmp/keystore.keystore
  cat >> "$FCI_BUILD_DIR/android/key.properties" <<EOF
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
keyPassword=$ANDROID_KEY_PASSWORD
storeFile=/tmp/keystore.keystore
EOF

  # set up local properties
  echo "flutter.sdk=$HOME/programs/flutter" > "$FCI_BUILD_DIR/android/local.properties"

  echo "--- Generate Google Service key for Android"
  GOOGLE_PLAY_STORE_JSON_KEY_PATH="$FCI_BUILD_DIR/android/app/google-play-store.json"
  echo $GOOGLE_PLAY_STORE_JSON_BASE64 | base64 --decode > $GOOGLE_PLAY_STORE_JSON_KEY_PATH

  cd $FCI_BUILD_DIR/android
  installGems
}

iosSteps() {
  echo "========================================"
  echo "|         iOS post-clone steps         |"
  echo "========================================"

  echo "--- Generate SSH key for Gitlab access from Fastlane Match"
  echo $SSH_KEY_FOR_FASTLANE_MATCH_BASE64 | base64 --decode > /tmp/bkey

  # adding custom ssh key to access private repository
  chmod 600 /tmp/bkey
  cp /tmp/bkey ~/.ssh/bkey
  ssh-add ~/.ssh/bkey

  cd $FCI_BUILD_DIR/ios
  installGems
}

androidSteps
iosSteps