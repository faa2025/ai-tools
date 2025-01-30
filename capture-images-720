#!/usr/bin/env bash

# --- 1. SETUP ---

# Name a folder by today's date, e.g., /var/www/html/images/2025-01-26
CURRENT_DATE=$(date +%Y-%m-%d)
TARGET_DIR="/var/www/html/images/${CURRENT_DATE}"
mkdir -p "$TARGET_DIR"

# Name of the HTML file we'll generate repeatedly
HTML_FILE="todays-images.html"

# Change into the target directory
cd "$TARGET_DIR" || exit 1

echo "Will continuously capture 4 snapshots every 3 seconds (2 seconds capture + 1 second wait)."
echo "Images accumulate here:   $TARGET_DIR"
echo "HTML will be regenerated: $TARGET_DIR/$HTML_FILE"
echo "After 1000 total images, all snapshots are deleted and we restart counting."
echo "Press Ctrl+C to stop."

# A counter to track how many images have been produced.
COUNTER=0

# --- 2. CONTINUOUS LOOP ---

while true
do
  # 2A. CAPTURE 4 NEW IMAGES (2 seconds total at 2 fps)
  #     Use a timestamp-based prefix so we never overwrite older images.
  #     Example filenames: snapshot-1674746279-01.jpg, snapshot-1674746279-02.jpg ...
  TS=$(date +%s)  # current Unix timestamp

  ffmpeg -y \
    -i "$(yt-dlp -f best -g "https://www.youtube.com/watch?v=T-u-BbFNNY4&ab_channel=JukkaJuslin")" \
    -r 2 \
    -frames:v 4 \
    -vf "rotate=PI,scale=iw*0.8:ih*0.8" \
    -f image2 "snapshot-${TS}-%02d.jpg"

  # Increase the counter by 4 (since we just created 4 images).
  COUNTER=$((COUNTER + 4))

  # 2B. If we've reached or exceeded 1000 images, remove them and reset the counter.
  if [ "$COUNTER" -ge 1000 ]; then
    echo "Reached 1000 images. Deleting all snapshots and restarting counter."
    rm -f snapshot-*.jpg
    COUNTER=0
  fi

  # 2C. REBUILD THE HTML PAGE so that newest images appear at the top.
  cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Today's Images ($CURRENT_DATE)</title>
  <!-- Auto-refresh can be enabled here if desired, for example:
       <meta http-equiv="refresh" content="1"> -->
</head>
<body>
  <h1>Newest Pictures on Top</h1>
  <p>This page is regenerated every time 4 new images are captured (every 3 seconds).<br>
     The newest pictures are shown at the top, older ones follow below.<br>
     Once 1000 images are reached, all snapshots are deleted and the count restarts.</p>
EOF

  # List all snapshot files, sorted by modification time (newest first).
  for IMG in $(ls -t snapshot-*.jpg 2>/dev/null); do
    cat <<EOF >> "$HTML_FILE"
  <div>
    <img src="${IMG}" width="40%" height="40%" alt="${IMG}" />
    <p>${IMG}</p>
  </div>
EOF
  done

  cat <<EOF >> "$HTML_FILE"
</body>
</html>
EOF

  echo "Captured 4 new pictures (timestamp $TS); total images so far: $COUNTER."
  echo "HTML rebuilt: $HTML_FILE"

  # 2D. WAIT 1 SECOND to complete a total of ~3 seconds per cycle:
  #     (2 seconds capturing + 1 second waiting = 3 seconds).
  sleep 1
done

