#!/bin/bash

WORK_DIR=$(cd $(dirname $0); pwd)
SOURCE_DIR="$WORK_DIR/Noto-Color-Emoji"
TARGET_DIR="$WORK_DIR/../../Noto-Color-Emoji"
EMOJI_FLAGS_FILE="$WORK_DIR/../emoji-flag.txt"


# 逐行读取 EMOJI_FILE
EMOJI_FLAGS=$(cat $EMOJI_FLAGS_FILE)
while read -r EMOJI_FLAG; do
    mv "${TARGET_DIR}/$(echo $EMOJI_FLAG | awk '{print $3}').svg" "${TARGET_DIR}/$(echo $EMOJI_FLAG | awk '{print $1,$2}' | sed 's/ /-/g').svg" 
done <<< "$EMOJI_FLAGS"