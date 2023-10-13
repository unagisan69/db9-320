#!/bin/bash

# Define announce URL for the torrent file
ANNOUNCE_URL="xxxx"

# Check if folder argument was provided
if [[ -z $1 ]]; then
    echo "Please provide a folder name as an argument."
    exit 1
fi

ORIGINAL_FOLDER="$1"

# Extract the base folder name without the path
BASE_FOLDER_NAME=$(basename "$ORIGINAL_FOLDER")

# Determine the new folder's name
if [[ $BASE_FOLDER_NAME == *FLAC* ]]; then
    NEW_FOLDER_NAME="${BASE_FOLDER_NAME/FLAC/320}"
else
    NEW_FOLDER_NAME="${BASE_FOLDER_NAME}[320]"
fi

# Get the directory path of the original folder
DIR_PATH=$(dirname "$ORIGINAL_FOLDER")

# Construct the new full path
NEW_FOLDER="$DIR_PATH/$NEW_FOLDER_NAME"

# Create the new folder only if it doesn't already exist
if [[ ! -d "$NEW_FOLDER" ]]; then
    mkdir -p "$NEW_FOLDER"
fi

# Copy non-FLAC files to the new folder
find "$ORIGINAL_FOLDER" -type f ! -name '*.flac' -exec cp {} "$NEW_FOLDER/" \;

# Copy FLAC files to the new folder
find "$ORIGINAL_FOLDER" -type f -name '*.flac' -exec cp {} "$NEW_FOLDER/" \;

# Convert FLAC files in the new folder to MP3 320kbps using sox and lame
for file in "$NEW_FOLDER"/*.flac; do
    NEW_FILE="${file%.flac}.mp3"
    sox "$file" -G -b 16 -t wav - rate -v -L 44100 dither | lame -S -h -b 320 --ignore-tag-errors - "$NEW_FILE"
    rm "$file"  # remove the FLAC file after conversion
done

# Create a private torrent file from the new folder
mktorrent -p -a "$ANNOUNCE_URL" -o "$HOME/watch/rtorrent/$(basename "$NEW_FOLDER").torrent" "$NEW_FOLDER"

echo "Process completed!"
