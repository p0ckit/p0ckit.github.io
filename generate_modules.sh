#!/bin/bash

# Path to your local p0ckit modules
MODULE_DIR="/home/tgrd/p0ckit/modules/core"
# Output file
OUTPUT_FILE="/home/tgrd/p0ckit.github.io/modules.html"

# Start building the HTML
echo "<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>p0ckit // modules</title>
    <link rel='stylesheet' href='style.css'>
</head>
<body>
    <div class='container'>
        <nav>
            <div class='logo'>p0ckit_</div>
            <div>
                <a href='index.html'>[home]</a>
                <a href='doc.html'>[docs]</a>
                <a href='modules.html'>[modules]</a>
                <a href='https://github.com/p0ckit/p0ckit' target='_blank'>[github]</a>
            </div>
        </nav>

        <header>
            <h1>[module_repository]</h1>
            <p class='dim'>A detailed list of all currently available security modules in the p0ckit core.</p>
        </header>

        <section>" > "$OUTPUT_FILE"

echo "<h2>Core Modules</h2>" >> "$OUTPUT_FILE"

# Loop through each file in the module directory
for module_path in "$MODULE_DIR"/*; do
    if [[ -f "$module_path" ]]; then
        module_name=$(basename "$module_path")
        
        echo "            <div class='code-block'>" >> "$OUTPUT_FILE"
        echo "                <h3>core/$module_name</h3>" >> "$OUTPUT_FILE"
        
        # Extract info
        info=$(sed -n '/#str_info/,/#end_info/p' "$module_path" | grep -v '#str_info' | grep -v '#end_info' | sed 's/^#//')
        echo "                <p>$info</p>" >> "$OUTPUT_FILE"
        
        # Extract options
        echo "                <p><strong>Options:</strong></p>" >> "$OUTPUT_FILE"
        echo "                <ul>" >> "$OUTPUT_FILE"
        
        # Parse options more carefully
        # We extract lines between #str_op and #end_op, strip the '#' and the indentation
        options=$(sed -n '/#str_op/,/#end_op/p' "$module_path" | grep -v '#str_op' | grep -v '#end_op' | sed 's/^#//' | sed 's/^[[:space:]]*//')
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                # Split into option name and description if it's in the format "name (description)"
                # Or just list the option if it's just a name.
                # For simplicity, let's just list it.
                echo "                    <li><code>$line</code></li>" >> "$OUTPUT_FILE"
            fi
        done <<< "$options"
        
        echo "                </ul>" >> "$OUTPUT_FILE"
        echo "            </div>" >> "$OUTPUT_FILE"
    fi
done

echo "</section>" >> "$OUTPUT_FILE"

echo "        <footer>
            <p class='dim'>p0ckit // modules // [end_of_file]</p>
        </footer>
    </div>
</body>
</html>" >> "$OUTPUT_FILE"

echo "Modules updated successfully."
