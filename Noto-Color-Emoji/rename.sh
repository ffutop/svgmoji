#!/bin/bash

for file in emoji_u*.svg; do
    if [ -f "$file" ]; then
        # 提取文件名中"emoji_u"之后的部分（不含扩展名）
        base=${file#emoji_u}
        base=${base%.svg}
        
        # 替换所有下划线为连字符，并转换为大写
        new_name=$(echo "$base" | tr '_' '-' | tr '[:lower:]' '[:upper:]')
        
        # 添加扩展名
        new_file="${new_name}.svg"
        
        # 执行重命名
        mv -v "$file" "$new_file"
    fi
done
