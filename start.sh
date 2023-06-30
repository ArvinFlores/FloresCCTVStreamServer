#!/bin/bash

source .env

CERT_PATH=$PWD/selfsign.crt
PKEY_PATH=$PWD/selfsign.key
MODE=$([ -z "$FLORESCCTV_ENV" ] && echo "DEV" || echo "$FLORESCCTV_ENV")
ASSET_DIR=$([ "$MODE" == "PROD" ] && echo "build" || echo "static")

echo "Running the server in $MODE mode"

sudo /usr/bin/uv4l \
--external-driver \
--device-name=video0 \
--server-option '--use-ssl=yes' \
--server-option "--ssl-certificate-file=$CERT_PATH" \
--server-option "--ssl-private-key-file=$PKEY_PATH" \
--server-option "--www-root-path=$PWD/$ASSET_DIR" \
--server-option '--www-index-file=index.html' \
--server-option '--www-port=9000' \
--server-option '--www-webrtc-signaling-path=/stream' \
--server-option '--www-use-ssl=yes' \
--server-option "--www-ssl-certificate-file=$CERT_PATH" \
--server-option "--www-ssl-private-key-file=$PKEY_PATH" \
--server-option '--enable-www-server=yes' \
--server-option '--enable-webrtc-video=yes' \
--server-option '--enable-webrtc-audio=yes' \
--server-option '--webrtc-receive-audio=yes'
