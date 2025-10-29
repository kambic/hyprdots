#!/usr/bin/env bash
# full_dash_transcode.sh
# Usage: ./full_dash_transcode.sh input.mp4 output_dir

set -e

INPUT="$1"
OUTPUT_DIR="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 <input_file> <output_dir>"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Define ABR ladder (resolution x bitrate)
declare -A LADDER=(
  ["240"]="500k"
  ["360"]="800k"
  ["480"]="1200k"
  ["720"]="2500k"
  ["1080"]="5000k"
)

# Temporary working directory
WORK_DIR="$OUTPUT_DIR/tmp"
mkdir -p "$WORK_DIR"

echo "=== TRANSCODING ==="
for RES in "${!LADDER[@]}"; do
  BITRATE="${LADDER[$RES]}"
  OUT_FILE="$WORK_DIR/video_${RES}p.mp4"
  echo "-> $RES p @ $BITRATE"
  ffmpeg -y -i "$INPUT" \
    -c:v libx264 -b:v "$BITRATE" -maxrate "$BITRATE" -bufsize $((2 * ${BITRATE%k}))k \
    -vf "scale=-2:$RES" -preset fast -profile:v main -keyint_min 48 -g 48 -sc_threshold 0 \
    -c:a aac -b:a 128k -ac 2 \
    "$OUT_FILE"
done

echo "=== FRAGMENTING ==="
for FILE in "$WORK_DIR"/*.mp4; do
  BASENAME=$(basename "$FILE" .mp4)
  echo "-> Fragmenting $BASENAME"
  mp4fragment "$FILE" "$WORK_DIR/${BASENAME}_frag.mp4"
done

echo "=== PACKAGING WITH BENTO4 ==="
mp4dash "$WORK_DIR"/*_frag.mp4 -o "$OUTPUT_DIR/dash" \
  --use-segment-timeline \
  --force

echo "=== CLEANUP ==="
rm -rf "$WORK_DIR"

echo "✅ Done. DASH content is in: $OUTPUT_DIR/dash"
echo "Manifest: $OUTPUT_DIR/dash/manifest.mpd"
