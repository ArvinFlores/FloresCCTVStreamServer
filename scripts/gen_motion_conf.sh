#!/bin/bash

source $(pwd)/.env

mkdir -p config

echo "# For more info on individual parameters see https://motion-project.github.io/motion_config.html

############################################################
# System Processing params
############################################################

daemon on
setup_mode off
log_level $([ "$FLORESCCTV_ENV" == "PROD" ] && echo "1" || echo "7")

############################################################
# Video4Linux Devices params
############################################################

videodevice /dev/video2

############################################################
# Image Processing params
############################################################

width 1024
height 768
framerate 15

############################################################
# Motion Detection params
############################################################

emulate_motion off
threshold 5000
despeckle_filter EedDl
minimum_motion_frames 5
event_gap 60
pre_capture 3
post_capture 0

############################################################
# Script Execution params
############################################################

on_motion_detected cd $(pwd) && $(pwd)/scripts/upload_recording.sh

############################################################
# Pictures params
############################################################

picture_output off

############################################################
# Movies params
############################################################

movie_output off

############################################################
# Webcontrol params
############################################################

webcontrol_localhost off

############################################################
# Live Stream params
############################################################

stream_localhost off" > config/motion.conf
