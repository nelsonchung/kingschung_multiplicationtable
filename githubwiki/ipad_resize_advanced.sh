#!/bin/bash

# 定義一個函數來執行 ffmpeg 指令
process_image() {
    local NAME="$1"
    local SCREEN_RESOLUTION="$2"
    local SCREEN_SIZE="$3"

    INPUT="${NAME}.png"
    OUTPUT="${NAME}_${SCREEN_SIZE}.png"

    ffmpeg -i "$INPUT" -vf "scale=$SCREEN_RESOLUTION" "$OUTPUT"
}

# 針對 iPad Pro 6代 螢幕的設定
SCREEN_RESOLUTION="2732*2048"
SCREEN_SIZE=ipadpro6
NAMES=("1_mainpage" "2_multiplication" "3_settings" "4_test_page")

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done

