#!/bin/bash

source $(pwd)/.env

ext="mp4"
timestamp=$(date +"%m-%d-%Y_%I:%M%p")
filename="$(pwd)/$timestamp.$ext"

ffmpeg -i /dev/video3 -t 10 "$filename"

curl -X POST -v -F file=@"$filename" "$FLORESCCTV_API_URL/recordings"

rm "$filename"
