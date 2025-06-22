#!/bin/bash

WORK_DIR=$(cd $(dirname $0); pwd)
SOURCE_DIR="$WORK_DIR/Fluent-Emoji"

function download() {
    # download fluent-emoji and unzip svgs
    curl -L https://github.com/microsoft/fluentui-emoji/archive/refs/heads/main.zip -o "${WORK_DIR}/Fluent-Emoji.zip"
    unzip "${WORK_DIR}/Fluent-Emoji.zip" "*/assets/*" -d ${SOURCE_DIR}
    mv ${SOURCE_DIR}/*/assets/* ${SOURCE_DIR}
}

function unified() {
    VARIANT=$1
    TARGET_DIR="$WORK_DIR/../../Fluent-Emoji-${VARIANT// /-}"

    for DIRNAME in ${SOURCE_DIR}/*/; do
        DIRNAME="${DIRNAME%/}"
        METADATA="${DIRNAME}/metadata.json"

        if [[ ! -f "$METADATA" ]]; then
            echo "skip directory $DIRNAME: not found metadata.json"
            continue
        fi

        UNICODE=$(jq -r '.unicode // empty' "$METADATA")
        if [[ -z "$UNICODE" ]]; then
            echo "skip directory $DIRNAME: not found .unicode field"
            continue
        fi

        UNICODE=$(echo "$UNICODE" | tr ' ' '-' | tr '[:lower:]' '[:upper:]')

        # if only has .unicode field
        if ! jq -e '.unicodeSkintones' "$METADATA" >/dev/null; then
            VARIANT_DIR="${DIRNAME}/${VARIANT}"
            if [[ -d "$VARIANT_DIR" ]]; then
                find "$VARIANT_DIR" -maxdepth 1 -type f -name '*.svg' | while read SVG; do
                    TARGET_FILENAME="${UNICODE}.svg"
                    cp -fv "$SVG" "$TARGET_DIR/$TARGET_FILENAME"
                done
            else
                echo "warn: not found ${VARIANT} in directory $DIRNAME"
            fi
        
        # contains .unicode and .unicodeSkintones
        else
            DEFAULT_DIR="${DIRNAME}/Default/${VARIANT}"
            if [[ -d "$DEFAULT_DIR" ]]; then
                find "$DEFAULT_DIR" -maxdepth 1 -type f -name '*.svg' | while read SVG; do
                    TARGET_FILENAME="${UNICODE}.svg"
                    cp -fv "$SVG" "$TARGET_DIR/$TARGET_FILENAME"
                done
            else
                echo "warn: not found Default/${VARIANT} in directory $DIRNAME"
            fi

            TONES=$(jq -r '.unicodeSkintones[]' "$METADATA")
            while IFS= read -r TONE; do
                TONE_CODE=$(grep -oE '1f3f[bcdef]' <<< "$TONE" | head -1)
                
                case $TONE_CODE in
                    1f3fb) TONE_DIRNAME="Light";;
                    1f3fc) TONE_DIRNAME="Medium-Light";;
                    1f3fd) TONE_DIRNAME="Medium";;
                    1f3fe) TONE_DIRNAME="Medium-Dark";;
                    1f3ff) TONE_DIRNAME="Dark";;
                esac
                TONE_DIR="${DIRNAME}/${TONE_DIRNAME}/${VARIANT}"
                
                if [[ -d "$TONE_DIR" ]]; then
                    TONE=$(echo "$TONE" | tr ' ' '-' | tr '[:lower:]' '[:upper:]')
                    find "$TONE_DIR" -maxdepth 1 -type f -name '*.svg' | while read SVG; do
                        TARGET_FILENAME="${TONE}.svg"
                        cp -fv "$SVG" "$TARGET_DIR/$TARGET_FILENAME"
                    done
                else
                    echo "warn: not found ${TONE_DIRNAME}/${VARIANT} in directory $DIRNAME"
                fi
            done <<< "$TONES"
        fi
    done
}

function compatFE0F() {
    VARIANT=$1
    TARGET_DIR="$WORK_DIR/../../Fluent-Emoji-$VARIANT"

    for FILENAME in $(find $TARGET_DIR | grep "FE0F"); do
        cp -v ${FILENAME} $(echo "$FILENAME" | sed 's/-FE0F//g')
    done

    FEOF_CODEPOINTS_ARRAY=$(cat "$WORK_DIR/../emoji-test.txt" | grep -v '^#\|^$' | grep 'FE0F' | sed 's/\ *;.*//g')
    while read -r FE0F_CODEPOINTS; do
        SOURCE_FILENAME="$(echo "$FE0F_CODEPOINTS" | sed 's/ FE0F//g' | sed 's/ /-/g').svg"
        TARGET_FILENAME="$(echo "$FE0F_CODEPOINTS" | sed 's/ /-/g').svg"
        cp -v "${TARGET_DIR}/${SOURCE_FILENAME}" "${TARGET_DIR}/${TARGET_FILENAME}"
    done <<< "$FEOF_CODEPOINTS_ARRAY"
}

unified Color
compatFE0F Color
unified Flat
compatFE0F Flat

unified 'High Contrast'
compatFE0F 'High Contrast'

rm ${SOURCE_DIR}
rm "${WORK_DIR}/Fluent-Emoji.zip"