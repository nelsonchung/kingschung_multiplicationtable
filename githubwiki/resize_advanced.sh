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

# 針對 6.7 吋螢幕的設定
SCREEN_RESOLUTION="1290*2796"
SCREEN_SIZE=67
NAMES=("1_mainpage_iphone" "2_multiplication_iphone" "3_settings_iphone" "4_test_page_iphone")

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done

# 針對 5.5 吋螢幕的設定
SCREEN_RESOLUTION="1242*2208"
SCREEN_SIZE=55

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done
