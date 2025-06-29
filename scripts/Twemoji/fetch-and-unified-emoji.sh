#!/bin/bash

WORK_DIR=$(cd $(dirname $0); pwd)
SOURCE_DIR="$WORK_DIR/Twemoji"
TARGET_DIR="$WORK_DIR/../../Twemoji"

function clean() {
    rm -rf ${SOURCE_DIR}
}
clean

function download() {
    mkdir ${SOURCE_DIR}
    # download noto-emoji and unzip svgs
    curl -L https://github.com/twitter/twemoji/archive/refs/tags/v14.0.2.zip -o "${WORK_DIR}/Twemoji.zip"
    unzip -j "${WORK_DIR}/Twemoji.zip" */svg/*.svg -d ${SOURCE_DIR}
}

function unified() {
    cd ${SOURCE_DIR}
    for FILENAME in *.svg; do
        if [ -f "$FILENAME" ]; then
            TARGET_FILENAME=${FILENAME%.svg}
            TARGET_FILENAME=$(echo "$TARGET_FILENAME" | tr '[:lower:]' '[:upper:]')
            # if TARGET_FILENAME length = 2 or prefix from "-" length = 2
            PREFIX_TARGET_FILENAME=${TARGET_FILENAME%-*}
            if [ "${#PREFIX_TARGET_FILENAME}" -eq 2 ]; then
                TARGET_FILENAME="00${TARGET_FILENAME}"
            fi

            TARGET_FILENAME="${TARGET_FILENAME}.svg"
            
            mv -v "$FILENAME" "$TARGET_FILENAME"
        fi
    done
    cd ${WORK_DIR}
}

function compatFE0F() {
    mkdir -p ${TARGET_DIR}
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
rm "${WORK_DIR}/Twemoji.zip"
