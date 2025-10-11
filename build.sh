#!/bin/bash

# Load configuration
load_config() {
    # Check if config.yaml exists
    if [ ! -f "config.yaml" ]; then
        echo "Error: config.yaml not found!"
        echo "Please create a config.yaml file with your site configuration."
        exit 1
    fi
    
    # Extract values from config.yaml (single source of truth)
    SITE_TITLE=$(grep "title:" config.yaml | sed 's/.*title: *"\([^"]*\)".*/\1/')
    OUTPUT_DIR=$(grep "output_dir:" config.yaml | sed 's/.*output_dir: *"\([^"]*\)".*/\1/')
    CSS_DIR=$(grep "css_dir:" config.yaml | sed 's/.*css_dir: *"\([^"]*\)".*/\1/')
    JS_DIR=$(grep "js_dir:" config.yaml | sed 's/.*js_dir: *"\([^"]*\)".*/\1/')
    TEMPLATE=$(grep "template:" config.yaml | sed 's/.*template: *"\([^"]*\)".*/\1/')
    MARKDOWN_PATTERN=$(grep "markdown_pattern:" config.yaml | sed 's/.*markdown_pattern: *"\([^"]*\)".*/\1/')
    
    # Footer configuration
    FOOTER_HOLDER=$(grep "holder:" config.yaml | sed 's/.*holder: *"\([^"]*\)".*/\1/')
    FOOTER_LICENSE_NAME=$(grep "license_name:" config.yaml | sed 's/.*license_name: *"\([^"]*\)".*/\1/')
    FOOTER_LICENSE_URL=$(grep "license_url:" config.yaml | sed 's/.*license_url: *"\([^"]*\)".*/\1/')
    
    # Extract license icons from config.yaml
    FOOTER_LICENSE_ICONS=""
    if grep -q "license_icons:" config.yaml; then
        FOOTER_LICENSE_ICONS=$(grep -A 10 "license_icons:" config.yaml | grep "    -" | sed 's/.*- *"\([^"]*\)".*/\1/')
    fi
    
    # Pandoc configuration
    PANDOC_FORMAT=$(grep "format:" config.yaml | sed 's/.*format: *"\([^"]*\)".*/\1/')
    PANDOC_OPTIONS=""
    
    # Parse Pandoc options from YAML
    if grep -q "options:" config.yaml; then
        PANDOC_OPTIONS=$(grep -A 10 "options:" config.yaml | grep "    -" | sed 's/.*- *"\([^"]*\)".*/\1/' | sed 's/^/--/g' | tr '\n' ' ')
    fi
    
    # Extract metadata from config.yaml for pandoc
    SITE_AUTHOR=$(grep "author:" config.yaml | sed 's/.*author: *"\([^"]*\)".*/\1/')
    SITE_DESCRIPTION=$(grep "description:" config.yaml | sed 's/.*description: *"\([^"]*\)".*/\1/')
    SITE_LICENSE=$(grep "license:" config.yaml | sed 's/.*license: *"\([^"]*\)".*/\1/')
    
    # Validate that required values are not empty
    if [ -z "$SITE_TITLE" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$CSS_DIR" ] || [ -z "$TEMPLATE" ]; then
        echo "Error: Missing required configuration values in config.yaml"
        echo "Required: site.title, build.output_dir, build.css_dir, build.template"
        exit 1
    fi
}

# Load configuration
load_config

echo "Building $SITE_TITLE with Pandoc..."
echo "Configuration: Output=$OUTPUT_DIR, CSS=$CSS_DIR, Template=$TEMPLATE"
echo "Pandoc options: $PANDOC_OPTIONS"
echo "🚀 Starting build..."

# Record start time with higher precision
BUILD_START=$(date +%s.%N)

# Clean and create output directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "🧹 Cleaning existing output directory: $OUTPUT_DIR"
    rm -rf "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

# Find all .md files using configured pattern and sort them by filename
md_files=($(ls content/$MARKDOWN_PATTERN | sort))

# Generate navigation menu dynamically
generate_nav_menu() {
    local nav_items=""
    local counter=1
    
    for md_file in "${md_files[@]}"; do
        # Extract the base name without extension and number prefix (keep hyphens for filename)
        base_name=$(echo "$md_file" | sed 's/^content\/[0-9]*-//' | sed 's/\.md$//')
        
        # Create display name by converting hyphens to spaces
        display_name=$(echo "$base_name" | sed 's/-/ /g')
        
        # Capitalize first letter for display
        first_char=$(echo "$display_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
        rest_chars=$(echo "$display_name" | cut -c2-)
        display_name="${first_char}${rest_chars}"
        
        # Create navigation item
        nav_items="${nav_items}                <li><a href=\"${base_name}.html\" class=\"nav-link\">${counter}. ${display_name}</a></li>\n"
        ((counter++))
    done
    
    echo -e "$nav_items"
}


# Generate footer HTML dynamically
generate_footer() {
    local footer_html=""
    
    footer_html="${footer_html}<footer style=\"text-align: center; margin-top: 2rem; padding: 1rem; border-top: 1px solid #8b4513; color: #654321; font-size: 0.9rem;\">\n"
    footer_html="${footer_html}        © by ${FOOTER_HOLDER}, licensed under <a href=\"${FOOTER_LICENSE_URL}\" style=\"color: #8b4513;\">${FOOTER_LICENSE_NAME}</a>"
    
    # Add license icons from config if they exist
    if [ -n "$FOOTER_LICENSE_ICONS" ]; then
        while IFS= read -r icon_url; do
            if [ -n "$icon_url" ]; then
                footer_html="${footer_html}<img src=\"${icon_url}\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
            fi
        done <<< "$FOOTER_LICENSE_ICONS"
    fi
    
    footer_html="${footer_html}\n    </footer>"
    
    echo -e "$footer_html"
}


# Generate the dynamic template
generate_template() {
    local nav_menu=$(generate_nav_menu)
    local footer=$(generate_footer)
    
    # Create temporary files for the content
    echo "$nav_menu" > nav_menu.tmp
    echo "$footer" > footer.tmp
    echo "$SITE_TITLE" > site_title.tmp
    
    # Replace placeholders using sed
    sed "/NAV_MENU_PLACEHOLDER/r nav_menu.tmp" "$TEMPLATE" | \
    sed "/NAV_MENU_PLACEHOLDER/d" | \
    sed "s/SITE_TITLE_PLACEHOLDER/$SITE_TITLE/g" | \
    sed "/FOOTER_PLACEHOLDER/r footer.tmp" | \
    sed "/FOOTER_PLACEHOLDER/d" > template_dynamic.html
    
    # Clean up temporary files
    rm nav_menu.tmp footer.tmp site_title.tmp
}

# Generate the dynamic template
generate_template

# Process markdown files in parallel for better performance
echo "📝 Converting markdown files in parallel..."
for md_file in "${md_files[@]}"; do
    # Extract the base name without extension and number prefix
    base_name=$(echo "$md_file" | sed 's/^content\/[0-9]*-//' | sed 's/\.md$//')
    
    # Check if TOC should be disabled for this file
    TOC_OPTIONS="$PANDOC_OPTIONS"
    if grep -q "^toc: *false" "$md_file"; then
        # Remove --toc from options for this file
        TOC_OPTIONS=$(echo "$PANDOC_OPTIONS" | sed 's/--toc//g')
        echo "Converting $md_file to $base_name.html (TOC disabled)..."
    else
        echo "Converting $md_file to $base_name.html..."
    fi
    
    pandoc "$md_file" -o "$OUTPUT_DIR/$base_name.html" --template=template_dynamic.html --metadata="author:$SITE_AUTHOR" --metadata="description:$SITE_DESCRIPTION" --metadata="license:$SITE_LICENSE" $TOC_OPTIONS &
done
wait  # Wait for all pandoc processes to complete
echo "✅ Markdown conversion complete"

# Combine CSS files
echo "🎨 Combining CSS files..."
cat $CSS_DIR/*.css > "$OUTPUT_DIR/styles.css"

# Combine JS files
echo "⚡ Combining JS files..."
cat $JS_DIR/*.js > "$OUTPUT_DIR/scripts.js"

# Copy other assets
echo "📁 Copying other assets..."
cp robots.txt "$OUTPUT_DIR/" &
cp -r images "$OUTPUT_DIR/" &
wait  # Wait for all background processes to complete
echo "✅ Assets processed successfully"

# Clean up temporary template
rm template_dynamic.html

# Calculate and display build time with 2 decimal places
BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc)

echo "🎉 Build complete! Files are in the '$OUTPUT_DIR' directory."
echo "⏱️  Build time: ${BUILD_TIME}s"
echo "📊 Generated pages:"
for md_file in "${md_files[@]}"; do
    base_name=$(echo "$md_file" | sed 's/^content\/[0-9]*-//' | sed 's/\.md$//')
    echo "  - $base_name.html"
done
echo ""
echo "🌐 Open $OUTPUT_DIR/index.html in your browser to view the site."