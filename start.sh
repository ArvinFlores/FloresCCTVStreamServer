#!/bin/bash

source .env

if [[ "$FLORESCCTV_ENV" != "PROD" && "$FLORESCCTV_ENV" != "DEV" ]]; then
  echo "An env hasn't been specified by FLORESCCTV_ENV, you must specify either DEV or PROD"
  exit 1
fi

USE_SSL=yes
STREAM_PORT=8080
CERT_PATH=$PWD/selfsign.crt
PKEY_PATH=$PWD/selfsign.key
ASSET_DIR=$([ "$FLORESCCTV_ENV" == "PROD" ] && echo "build" || echo "static")
VIDEO_NODE=$([ $1 == "--motion" ] && echo "video1" || echo "video0")

if [[ $FLORESCCTV_ENV == "PROD" ]]; then
  source scripts/build.sh
fi

if [[
  -n "$FLORESCCTV_JANUS_URL" || \
  -n "$FLORESCCTV_JANUS_ROOT" || \
  -n "$FLORESCCTV_JANUS_ROOM" || \
  -n "$FLORESCCTV_JANUS_USERNAME"
]]; then
  if [[
    -z "$FLORESCCTV_JANUS_URL" || \
    -z "$FLORESCCTV_JANUS_ROOT" || \
    -z "$FLORESCCTV_JANUS_ROOM" || \
    -z "$FLORESCCTV_JANUS_USERNAME"
  ]]; then
    echo -e "You must specify:\n"
    echo -e "FLORESCCTV_JANUS_URL, FLORESCCTV_JANUS_ROOT, FLORESCCTV_JANUS_ROOM, FLORESCCTV_JANUS_USERNAME\n"
    echo "if you wish to try connecting to the Janus server, not all variables were set so skipping for now"
  else
    echo "Attempting to connect to the Janus server at $FLORESCCTV_JANUS_URL$FLORESCCTV_JANUS_ROOT"
    source scripts/janus_connect.sh $USE_SSL $STREAM_PORT &
  fi
fi

if [[ $1 == "--motion" ]]; then
  trap "killall -s SIGKILL motion" SIGINT SIGTERM EXIT
  ffmpeg -f video4linux2 \
    -i /dev/video0 \
    -vcodec copy \
    -acodec copy \
    -f v4l2 /dev/video1 \
    -f v4l2 /dev/video2 \
    -f v4l2 /dev/video3 > /dev/null 2>&1 &
  motion -c ./config/motion.conf > /dev/null 2>&1
  echo "motion detection enabled"
  echo "video loopback devices have been created"
fi

echo "Running the server in $FLORESCCTV_ENV mode"

sudo /usr/bin/uv4l \
--external-driver \
--device-name="$VIDEO_NODE" \
--server-option "--port=$STREAM_PORT" \
--server-option "--use-ssl=$USE_SSL" \
--server-option "--ssl-certificate-file=$CERT_PATH" \
--server-option "--ssl-private-key-file=$PKEY_PATH" \
--server-option "--www-root-path=$PWD/$ASSET_DIR" \
--server-option '--www-index-file=index.html' \
--server-option '--www-port=9000' \
--server-option '--www-webrtc-signaling-path=/stream' \
--server-option "--www-use-ssl=$USE_SSL" \
--server-option "--www-ssl-certificate-file=$CERT_PATH" \
--server-option "--www-ssl-private-key-file=$PKEY_PATH" \
--server-option '--enable-www-server=yes' \
--server-option '--enable-webrtc-video=yes' \
--server-option '--enable-webrtc-audio=yes' \
--server-option '--webrtc-receive-audio=yes'
