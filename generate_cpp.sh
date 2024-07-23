#!/bin/bash

# Check if the directory is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Output file
output_file="$directory/frontend.cpp"

# Start writing the C++ code
echo "// Auto-generated via generate_cpp.sh" > "$output_file"
echo >> "$output_file"
echo "#include <ESP8266WebServer.h>" >> "$output_file"
echo "#include \"frontend.h\"" >> "$output_file"
echo >> "$output_file"
echo "extern ESP8266WebServer server;" >> "$output_file"
echo >> "$output_file"
echo "void SETUP_FRONTEND_SERVER() {" >> "$output_file"


# Iterate over each file in the directory
for file in "$directory"/*; do
    # Skip directories
    if [ -d "$file" ]; then
        continue
    fi
    
    # Get the file extension
    extension="${file##*.}"
    
    # Skip .h files
    if [ "$extension" == "cpp" ]; then
        continue
    fi
    
    filename=$(basename -- "$file")

    escaped_content=$(sed 's/\\/\\\\/g' "$file" | sed 's/"/\\"/g' | tr -d '\n')
    mime_type=$(file --mime-type -b "$file")

    # Handle JavaScript files explicitly
    if [ "$extension" == "js" ]; then
        mime_type="application/javascript"
    fi
    
    # Add the server routing to the output file
    echo "  server.on(\"/$filename\", []() {" >> "$output_file"
    echo "    server.send(200, \"$mime_type\", \"$escaped_content\");" >> "$output_file"
    echo "  });" >> "$output_file"
    echo >> "$output_file"
done

echo "}" >> "$output_file"

echo "Saved to $output_file"
