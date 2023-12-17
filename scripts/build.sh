#!/bin/bash

CURR_DIR=$PWD
PROJECTS_PATH="${PWD%/*}"
ASSETS_DIR=FloresCCTVWebAssets
WEB_ASSETS_PATH=$PROJECTS_PATH/$ASSETS_DIR

log() {
  echo -e "====================================================================================================\n"
  echo -e "\033[1m$1\033[0m\n"
  echo -e "====================================================================================================\n"
}

if [[ -d $CURR_DIR/build ]]; then
  log "build/ folder exists already, skipping build... remove the build/ folder to rebuild the assets if desired"
else
  log "Cloning the web assets repo into $PROJECTS_PATH"
  cd $PROJECTS_PATH
  git clone git@github.com:ArvinFlores/FloresCCTVWebAssets.git
  cd $ASSETS_DIR

  log "Installing the project dependencies for $ASSETS_DIR"
  npm install

  log "Building the production web assets for $ASSETS_DIR"
  echo "CAMERA_IP=$(hostname -I | awk '{print $1}')" >> .env
  echo "FLORES_CCTV_API_URL=$FLORESCCTV_API_URL" >> .env
  echo "JANUS_URL=$FLORESCCTV_JANUS_URL$FLORESCCTV_JANUS_ROOT" >> .env
  echo "JANUS_ROOM=$FLORESCCTV_JANUS_ROOM" >> .env
  npm run build

  log "Copying the production web assets into $CURR_DIR/build"
  mkdir -p $CURR_DIR/build
  rm -f $CURR_DIR/build/*
  cp -r build/* $CURR_DIR/build
  cd $CURR_DIR

  log "Removing $WEB_ASSETS_PATH"
  rm -rf $WEB_ASSETS_PATH

  log "Creating the health.json file"
  python $CURR_DIR/scripts/health.py

  log "Streaming server is ready to run in production"
fi
