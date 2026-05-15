#!/bin/bash

# Path to your local p0ckit root
P0CKIT_ROOT="/home/tgrd/p0ckit"
# Path to the runner
RUNNER="$P0CKIT_ROOT/p0ckit.sh"
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

# Loop through each module file
for module_path in "$P0CKIT_ROOT/modules/core"/*; do
    if [[ -f "$module_path" ]]; then
        module_name=$(basename "$module_path")
        
        echo "            <div class='code-block'>" >> "$OUTPUT_FILE"
        echo "                <h3>core/$module_name</h3>" >> "$OUTPUT_FILE"

        # Attempt 1: Parse via p0ckit metadata (#str_op, #str_info)
        info=$(sed -n '/#str_info/,/#end_info/p' "$module_path" | grep -v '#str_info' | grep -v '#end_info' | sed 's/^#//' | sed 's/^[[:space:]]*//')
        options=$(sed -n '/#str_op/,/#end_op/p' "$module_path" | grep -v '#str_op' | grep -v '#end_op' | sed 's/^#//' | sed 's/^[[:space:]]*//')

        # Attempt 2: Fallback for Python/argparse modules
        if [[ -z "$info" || -z "$options" ]]; then
            # Improved Python Argparse Scraper
            # 1. Scrape help text for the module description
            info=$(grep -E 'help="[^"]+"' "$module_path" | head -n 1 | sed -E 's/.*help="([^"]*)".*/\1/')
            if [[ -z "$info" ]]; then
                info="No description available."
            fi
            
            # 2. Scrape flags and help text for options
            # We specifically look for a string starting with '-' or '--' followed by the help text
            options=$(grep "add_argument" "$module_path" | sed -E 's/.*"(-[a-zA-Z0-9-]+|--[a-zA-Z0-9-]+)".*help="([^"]*)".*/\1: \2/')
        fi

        # Write info
        echo "                <p>$info</p>" >> "$OUTPUT_FILE"

        # Write options
        if [[ -n "$options" ]]; then
            echo "                <p><strong>Options:</strong></p>" >> "$OUTPUT_FILE"
            echo "                <ul>" >> "$OUTPUT_FILE"
            while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    echo "                    <li><code>$line</code></li>" >> "$OUTPUT_FILE"
                fi
            done <<< "$options"
            echo "                </ul>" >> "$OUTPUT_FILE"
        fi
        
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
