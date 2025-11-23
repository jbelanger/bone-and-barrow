#!/usr/bin/env bash
set -euo pipefail

# Export all .gd and .tscn files from the Godot project
# Creates both a consolidated file AND individual files per top-level folder
# Excludes: .godot (cache), _developer (docs/raw assets), tools (scripts)

OUTPUT_DIR="."
CONSOLIDATED_FILE="./exported_code.txt"
PROJECT_ROOT=".."

echo "Exporting Godot files from $PROJECT_ROOT"
echo ""

# Create consolidated export
echo "Creating consolidated export: $CONSOLIDATED_FILE"
find "$PROJECT_ROOT" -type f \
  \( -name "*.gd" -o -name "*.tscn" \) \
  ! -path "*/.godot/*" \
  ! -path "*/_developer/*" \
  ! -path "*/tools/*" \
  -exec sh -c 'echo "===== {} ====="; cat "{}"; echo ""' \; \
  > "$CONSOLIDATED_FILE"

# Count total files
gd_count=$(grep -c "\.gd =====$" "$CONSOLIDATED_FILE" || echo "0")
tscn_count=$(grep -c "\.tscn =====$" "$CONSOLIDATED_FILE" || echo "0")

echo "  .gd files: $gd_count"
echo "  .tscn files: $tscn_count"
echo ""

# Create individual exports for each top-level directory
echo "Creating individual folder exports:"
for dir in "$PROJECT_ROOT"/*; do
  if [ -d "$dir" ]; then
    dir_name=$(basename "$dir")

    # Skip excluded directories
    if [[ "$dir_name" == ".godot" || "$dir_name" == "_developer" || "$dir_name" == "tools" ]]; then
      continue
    fi

    output_file="${OUTPUT_DIR}/exported_code_${dir_name}.txt"

    # Find files in this specific directory
    find "$dir" -type f \
      \( -name "*.gd" -o -name "*.tscn" \) \
      ! -path "*/.godot/*" \
      -exec sh -c 'echo "===== {} ====="; cat "{}"; echo ""' \; \
      > "$output_file"

    # Count files in this directory
    file_count=$(grep -c "=====" "$output_file" || echo "0")

    if [ "$file_count" -gt 0 ]; then
      echo "  $dir_name: $file_count files -> $output_file"
    else
      # Remove empty files
      rm "$output_file"
    fi
  fi
done

echo ""
echo "Export complete!"
echo "  Consolidated: $CONSOLIDATED_FILE"
echo "  Individual files: exported_code_*.txt"
