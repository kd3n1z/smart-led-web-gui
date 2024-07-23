#!/bin/bash

# Default values
base_url=""
directory=""

# Function to print usage
print_usage() {
    echo "Usage: $0 --base-url <base_url> <directory>"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-url)
            base_url="$2"
            shift 2
            ;;
        *)
            directory="$1"
            shift
            ;;
    esac
done

# Check if directory is provided
if [ -z "$directory" ]; then
    print_usage
fi

# Output file
output_file="$directory/frontend.cpp"

# Start writing the C++ code
cat <<EOF > "$output_file"
// Auto-generated via generate_cpp.sh
// https://github.com/kd3n1z/smart-led-web-gui

#include <ESP8266WebServer.h>
#include "frontend.h"

extern ESP8266WebServer server;

void SETUP_FRONTEND_SERVER() {
EOF

# Function to process files in a directory
process_directory() {
    local dir="$1"
    
    # Iterate over each file and directory
    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        if [ -d "$entry" ]; then
            # Recursively process subdirectories
            process_directory "$entry"
        else
            # Process files
            local file="$entry"
            local filename=$(basename -- "$file")
            local extension="${filename##*.}"
            local relative_path="${file#"$directory/"}"
            
            # Skip .cpp files
            [ "$extension" == "cpp" ] && continue
            
            # Escape content for C++ and determine MIME type
            local escaped_content=$(sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' "$file" | tr -d '\n')
            local mime_type=$(file --mime-type -b "$file")
            
            # Handle specific MIME types
            case "$extension" in
                js) mime_type="application/javascript" ;;
                css) mime_type="text/css" ;;
            esac
            
            local url="$base_url/$relative_path"
            
            # Handle index.html redirection
            if [ "$filename" == "index.html" ]; then
                local subdir=$(basename "$(dirname "$relative_path")")
                [ "$subdir" == "." ] && subdir=""
                cat <<EOF >> "$output_file"
  server.on("$base_url/$subdir", []() {
    server.sendHeader("Location", String("$url"), true);
    server.send(302, "text/plain", "");
  });
EOF
            fi
            
            # Add server routing for other files
            cat <<EOF >> "$output_file"
  server.on("$url", []() {
    server.send(200, "$mime_type", "$escaped_content");
  });
EOF
        fi
    done
}

# Start processing from the provided directory
process_directory "$directory"

# Close the C++ function
echo "}" >> "$output_file"

echo "Saved to $output_file"
