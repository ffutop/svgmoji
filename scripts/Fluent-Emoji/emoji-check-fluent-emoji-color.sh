#!/bin/bash

WORK_DIR=$(cd $(dirname $0); pwd)
RESOURCE_DIR="$WORK_DIR/../../Fluent-Emoji-Color"
STANDARD_EMOJI_FILE="$WORK_DIR/../emoji-test.txt"
VALID_EMOJI_FILE="$RESOURCE_DIR/valid-emoji.txt"

# 逐行读取 EMOJI_FILE
EMOJI_CONTEXT=$(cat $STANDARD_EMOJI_FILE)
while read -r LINE; do
    # '# group' as prefix
    if [[ $LINE == '# group'* ]]; then
        echo "$LINE" >> $VALID_EMOJI_FILE
        continue
    fi

    # '# subgroup' as prefix
    if [[ $LINE == '# subgroup'* ]]; then
        echo "$LINE" >> $VALID_EMOJI_FILE
        continue
    fi

    # '#' as prefix
    if [[ $LINE == '#'* ]]; then
        # skip
        continue
    fi

    # empty line
    if [[ -z $LINE ]]; then
        continue
    fi

    # 提取注释之前的部分
    CODEPOINTS=$(echo $LINE | sed 's/\ *;.*//g')
    # 替换 ' ' 为 -
    CODEPOINTS=${CODEPOINTS// /-}
    # 构建文件名
    FILENAME="${CODEPOINTS}.svg"
    # 检查文件是否存在
    if [ ! -f "${RESOURCE_DIR}/${FILENAME}" ]; then
        echo "$LINE" | sed 's/^/# /' | sed 's/\ \ ;/;/' >> $VALID_EMOJI_FILE
    else
        echo "$LINE" >> $VALID_EMOJI_FILE
    fi
done <<< "$EMOJI_CONTEXT"
