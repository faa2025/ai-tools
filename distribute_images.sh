#!/usr/bin/env bash
#
# Distribute 200 images from has_trains to (train/train, test/train, validation/train)
# and 200 images from no_trains to (train/not_train, test/not_train, validation/not_train).
# The script moves the files, so be sure you actually want to remove them from the source directories!

#####################
# Configuration
#####################

# How many images to move from each category
NUM_IMAGES=200

# Ratios for train, test, validation
TRAIN_RATIO=0.7
TEST_RATIO=0.15
VAL_RATIO=0.15

# Source directories
TRAIN_SRC="has_trains"
NOT_TRAIN_SRC="no_trains"

# Destination subdirectories
TRAIN_DEST_TRAIN="train/train"
TRAIN_DEST_TEST="test/train"
TRAIN_DEST_VAL="validation/train"

NOT_TRAIN_DEST_TRAIN="train/not_train"
NOT_TRAIN_DEST_TEST="test/not_train"
NOT_TRAIN_DEST_VAL="validation/not_train"

#####################
# Helper function
#####################

distribute_category() {
  local src_dir="$1"           # e.g. "has_trains" or "no_trains"
  local dest_train="$2"        # e.g. "train/train"
  local dest_test="$3"         # e.g. "test/train"
  local dest_val="$4"          # e.g. "validation/train"
  local num_images="$5"        # e.g. 200
  local train_ratio="$6"       # e.g. 0.7
  local test_ratio="$7"        # e.g. 0.15
  local val_ratio="$8"         # e.g. 0.15

  # Figure out the exact count of images for train/test/val
  local train_count=$(awk -v n="$num_images" -v r="$train_ratio" 'BEGIN {print int(n*r)}')
  local test_count=$(awk -v n="$num_images" -v r="$test_ratio"  'BEGIN {print int(n*r)}')
  # Put remainder in val_count to account for any rounding differences
  local val_count=$(( num_images - train_count - test_count ))

  echo "Source: $src_dir"
  echo "Moving $num_images images → ($train_count train, $test_count test, $val_count validation)"

  # Make sure destination directories exist
  mkdir -p "$dest_train" "$dest_test" "$dest_val"

  # Get up to num_images from src_dir, randomly
  # Adjust the pattern *.jpg if you have PNG, JPEG, etc.
  mapfile -t SELECTED_FILES < <(ls -1 "$src_dir"/* 2>/dev/null | shuf | head -n "$num_images")

  # If fewer than $num_images files exist, the array will have fewer items
  local actual_count=${#SELECTED_FILES[@]}

  if [ "$actual_count" -eq 0 ]; then
    echo "No images found in $src_dir to move. Skipping..."
    return
  fi

  echo "Actual files found: $actual_count"

  # Move to train
  for (( i=0; i<train_count && i<actual_count; i++ )); do
    mv "${SELECTED_FILES[$i]}" "$dest_train"
  done

  # Move to test
  for (( i=train_count; i<train_count+test_count && i<actual_count; i++ )); do
    mv "${SELECTED_FILES[$i]}" "$dest_test"
  done

  # Move to validation
  for (( i=train_count+test_count; i<train_count+test_count+val_count && i<actual_count; i++ )); do
    mv "${SELECTED_FILES[$i]}" "$dest_val"
  done

  echo "Done distributing files from $src_dir."
  echo
}

#####################
# Main
#####################

# Distribute "train" images (has_trains)
distribute_category \
  "$TRAIN_SRC" \
  "$TRAIN_DEST_TRAIN" \
  "$TRAIN_DEST_TEST" \
  "$TRAIN_DEST_VAL" \
  "$NUM_IMAGES" \
  "$TRAIN_RATIO" \
  "$TEST_RATIO" \
  "$VAL_RATIO"

# Distribute "not_train" images (no_trains)
distribute_category \
  "$NOT_TRAIN_SRC" \
  "$NOT_TRAIN_DEST_TRAIN" \
  "$NOT_TRAIN_DEST_TEST" \
  "$NOT_TRAIN_DEST_VAL" \
  "$NUM_IMAGES" \
  "$TRAIN_RATIO" \
  "$TEST_RATIO" \
  "$VAL_RATIO"

echo "All done!"
