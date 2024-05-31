#!/bin/sh
rootdir="/mnt/SDCARD/Roms"
count=0

if [ $# -gt 0 ]; then
    targets="$1"
else
    targets="PS SEGACD NEOCD PCE PCFX AMIGA"
fi

cd "$rootdir"

find $targets -maxdepth 3 -name *.bin -type f | (

    while read target; do
        dir_path=$(dirname "$target")
        target_name=$(basename "$target")
        target_base="${target_name%.*}"
        cue_path="$dir_path/$target_base.cue"

        if echo "$target_base" | grep -q ' (Track [0-9][0-9]*)$'; then
            continue
        fi

        if [ -f "$cue_path" ]; then
            continue
        fi

        echo "FILE \"$target_name\" BINARY
  TRACK 01 MODE1/2352
    INDEX 01 00:00:00" >"$cue_path"

        let count++
    done

    echo "$count cue $([ $count -eq 1 ] && (echo "file") || (echo "files")) created"
)

find $targets -maxdepth 1 -type f -name "*_cache7.db" -exec rm -f {} \;

/mnt/SDCARD/System/bin/sdl2imgshow \
    -i "/mnt/SDCARD/trimui/res/crossmix-os/bg-info.png" \
    -f "/mnt/SDCARD/System/resources/DejaVuSans.ttf" \
    -s 50 \
    -c "220,220,220" \
    -t "$count cue file(s) created." &

sleep 3
pkill -f sdl2imgshow
