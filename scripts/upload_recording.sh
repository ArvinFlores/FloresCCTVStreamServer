#!/bin/bash

source $(pwd)/.env

ext="mp4"
timestamp=$(date +"%m-%d-%Y_%I:%M%p")
filename="$(pwd)/$timestamp.$ext"
last_timestamp_file=$(pwd)/tmp/motion_timestamp.txt
video_duration_secs=20
wait_secs=10

record() {
  ffmpeg -hide_banner -thread_queue_size 512 -f alsa -ac 1 -i default -thread_queue_size 512 -f video4linux2 -i /dev/video3 -t $video_duration_secs "$filename"
  if [[ $(stat -c%s $filename) -ge 1000 ]]; then
    curl -X POST -v -F file=@"$filename" -k "$FLORESCCTV_API_URL/recordings"
  fi
  rm "$filename"
}

if [[ -f $last_timestamp_file ]]; then
  last_timestamp=$(cat $last_timestamp_file)
else
  record &
  last_timestamp=$(date --iso-8601=seconds)
  mkdir -p $(pwd)/tmp
  echo $last_timestamp > $last_timestamp_file
  exit 0
fi

last_call=$(( $(date -d "$(date --iso-8601=seconds)" "+%s") - $(date -d "$last_timestamp" "+%s") ))

if [[ $last_call -le $(($video_duration_secs + $wait_secs)) ]]; then
  exit 0
else
  record &
  echo $(date --iso-8601=seconds) > $last_timestamp_file
fi
