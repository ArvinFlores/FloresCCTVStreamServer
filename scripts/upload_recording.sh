#!/bin/bash

source $(pwd)/.env

ext="mp4"
timestamp=$(date +"%m-%d-%Y_%I:%M%p")
filename="$(pwd)/$timestamp.$ext"

ffmpeg -f alsa -ac 1 -i hw:1,0 -f video4linux2 -i /dev/video3 -t 10 "$filename"

curl -X POST -v -F file=@"$filename" -k "$FLORESCCTV_API_URL/recordings"

rm "$filename"
