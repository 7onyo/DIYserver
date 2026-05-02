#!/bin/bash
cd /data/shares/media/music/ || exit 1

for dir in */; do
    find "$dir" -type f -name "*.flac" | sort > "${dir%/}.m3u"
done
