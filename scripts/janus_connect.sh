#!/bin/bash

PROTOCOL=$([ "$1" == "yes" ] && echo "https" || echo "http")
URL="$PROTOCOL://localhost:$2/janus?\
gateway_url=$FLORESCCTV_JANUS_URL&\
gateway_root=$FLORESCCTV_JANUS_ROOT&\
room=$FLORESCCTV_JANUS_ROOM&\
username=$FLORESCCTV_JANUS_USERNAME&\
publish=1&\
vformat=60&\
hw_vcodec=0&\
subscribe=0&\
reconnect=1&\
action=Start"

curl --connect-timeout 5 \
  --max-time 5 \
  --retry 10 \
  --retry-delay 0 \
  --retry-max-time 60 \
  --retry-all-errors \
  -s \
  -o /dev/null \
  --insecure $(sed "s/ /%20/g" <<< "$URL")
