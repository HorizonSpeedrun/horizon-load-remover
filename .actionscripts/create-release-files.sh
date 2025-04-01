#!/bin/bash

SCRIPTPATH=$(dirname "$(realpath -s "$0")")
REPOROOT=$(dirname "$SCRIPTPATH")

cd "$REPOROOT"

TARGETFOLDER=$REPOROOT/generated

# Clean target folder
rm $TARGETFOLDER/*

# Zip up files for Video LR
echo "Create ZIP file for video LR"
FILENAME_VIDEO=files-for-video-LR.zip
git ls-files -- ./files ':!:*.md' | zip -FS -q -@ "$TARGETFOLDER/$FILENAME_VIDEO"

# Create PDFs
echo "Create PDF from README"
pandoc --from=gfm --to=pdf -o "$TARGETFOLDER/README.pdf" "$REPOROOT/README.md"

echo "Done"
