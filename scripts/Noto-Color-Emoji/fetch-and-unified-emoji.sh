#!/bin/bash

WORK_DIR=$(cd $(dirname $0); pwd)
SOURCE_DIR="$WORK_DIR/Noto-Color-Emoji"
TARGET_DIR="$WORK_DIR/../../Noto-Color-Emoji"

function clean() {
    rm -rf ${SOURCE_DIR}
}
clean

function download() {
    # download noto-emoji and unzip svgs
    curl -L https://github.com/googlefonts/noto-emoji/archive/refs/tags/v2.047.zip -o "${WORK_DIR}/Noto-Color-Emoji.zip"
    unzip -j "${WORK_DIR}/Noto-Color-Emoji.zip" */svg/*.svg -d ${SOURCE_DIR}
}

function unified() {
    cd ${SOURCE_DIR}
    for FILENAME in emoji_u*.svg; do
        if [ -f "$FILENAME" ]; then
            # extract BASE_CODEPOINTS from FILENAME (remove prefix "emoji_u" and suffix ".svg")
            BASE_CODEPOINTS=${FILENAME#emoji_u}
            BASE_CODEPOINTS=${BASE_CODEPOINTS%.svg}
            
            TARGET_FILENAME=$(echo "$BASE_CODEPOINTS" | tr '_' '-' | tr '[:lower:]' '[:upper:]')
            TARGET_FILENAME="${TARGET_FILENAME}.svg"
            
            mv -v "$FILENAME" "$TARGET_FILENAME"
        fi
    done
    cd ${WORK_DIR}
}

function compatFE0F() {
    FEOF_CODEPOINTS_ARRAY=$(cat "$WORK_DIR/../emoji-test.txt" | grep -v '^#\|^$' | grep 'FE0F' | sed 's/\ *;.*//g')
    while read -r FE0F_CODEPOINTS; do
        SOURCE_FILENAME="$(echo $FE0F_CODEPOINTS | sed 's/ FE0F//g' | sed 's/ /-/g').svg"
        TARGET_FILENAME="$(echo $FE0F_CODEPOINTS | sed 's/ /-/g').svg"
        cp -v ${SOURCE_DIR}/${SOURCE_FILENAME} ${SOURCE_DIR}/${TARGET_FILENAME}
    done <<< "$FEOF_CODEPOINTS_ARRAY"
}

function moveToTarget() {
    mv ${SOURCE_DIR}/*.svg ${TARGET_DIR}
}

download
unified
compatFE0F
moveToTarget
clean
rm "${WORK_DIR}/Noto-Color-Emoji.zip"