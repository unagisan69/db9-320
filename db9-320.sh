#!/bin/bash

# Define the announce URL for the torrent
ANNOUNCE_URL="xxxx"

# Check for input folder
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_name>"
    exit 1
fi

ORIGINAL_FOLDER="$1"

# Check if the folder exists
if [ ! -d "$ORIGINAL_FOLDER" ]; then
    echo "Error: Folder not found!"
    exit 1
fi

# Determine the new folder's name
if [[ $ORIGINAL_FOLDER == *FLAC* ]]; then
    NEW_FOLDER="${ORIGINAL_FOLDER/FLAC/320}"
else
    NEW_FOLDER="${ORIGINAL_FOLDER}[320]"
fi

# Create the new folder
mkdir -p "$NEW_FOLDER"

# Copy non-FLAC files to the new folder
find "$ORIGINAL_FOLDER" -type f ! -name '*.flac' -exec cp {} "$NEW_FOLDER/" \;

# Copy FLAC files to the new folder
find "$ORIGINAL_FOLDER" -type f -name '*.flac' -exec cp {} "$NEW_FOLDER/" \;

# Convert FLAC files in the new folder to MP3 320kbps while preserving metadata
#for file in "$NEW_FOLDER"/*.flac; do
#    NEW_FILE="${file%.flac}.mp3"
#    ffmpeg -i "$file" -q:a 0 -map_metadata 0 -id3v2_version 3 "$NEW_FILE"
#    rm "$file"  # remove the FLAC file after conversion
#done

for file in "$NEW_FOLDER"/*.flac; do
    NEW_FILE="${file%.flac}.mp3"
    sox "$file" -G -b 16 -t wav - rate -v -L 44100 dither | lame -S -h -b 320 --ignore-tag-errors - "$NEW_FILE"
    rm "$file"  # remove the FLAC file after conversion
done

# Create a torrent file
mktorrent -p -a "$ANNOUNCE_URL" -o "$HOME/watch/rtorrent/$(basename "$NEW_FOLDER").torrent" "$NEW_FOLDER"

echo "Script finished successfully."
