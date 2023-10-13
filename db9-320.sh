#!/bin/bash
# Define announce URL for the torrent file
ANNOUNCE_URL="xxxx"

if [[ -z $1 ]]; then
    echo "Please provide a folder name as an argument."
    exit 1
fi

ORIGINAL_FOLDER="$1"

BASE_FOLDER_NAME=$(basename "$ORIGINAL_FOLDER")

if [[ $BASE_FOLDER_NAME == *FLAC* ]]; then
    NEW_FOLDER_NAME="${BASE_FOLDER_NAME/FLAC/320}"
else
    NEW_FOLDER_NAME="${BASE_FOLDER_NAME}[320]"
fi

DIR_PATH=$(dirname "$ORIGINAL_FOLDER")
NEW_FOLDER="$DIR_PATH/$NEW_FOLDER_NAME"

if [[ ! -d "$NEW_FOLDER" ]]; then
    mkdir -p "$NEW_FOLDER"
fi

# Use a while-loop with a read command for file traversal
find "$ORIGINAL_FOLDER" -type f ! -name '*.flac' | while IFS= read -r file; do
    cp "$file" "$NEW_FOLDER/"
done

find "$ORIGINAL_FOLDER" -type f -name '*.flac' | while IFS= read -r file; do
    cp "$file" "$NEW_FOLDER/"
done

# Modify the FLAC to MP3 conversion loop
find "$NEW_FOLDER" -type f -name '*.flac' | while IFS= read -r file; do
    NEW_FILE="${file%.flac}.mp3"
    sox "$file" -G -b 16 -t wav - rate -v -L 44100 dither | lame -S -h -b 320 --ignore-tag-errors - "$NEW_FILE"
    rm "$file"
done

mktorrent -p -a "$ANNOUNCE_URL" -o "$HOME/watch/rtorrent/$(basename "$NEW_FOLDER").torrent" "$NEW_FOLDER"

echo "Process completed!"
# Create a private torrent file from the new folder
mktorrent -p -a "$ANNOUNCE_URL" -o "$HOME/watch/rtorrent/$(basename "$NEW_FOLDER").torrent" "$NEW_FOLDER"

echo "Process completed!"
