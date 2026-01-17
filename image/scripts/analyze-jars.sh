#!/bin/bash

# Script to analyze JAR files in the Nexus tar package
# Usage: ./analyze-jars.sh <nexus-version> <download-url> [output-file]

set -e

NEXUS_VERSION="${1:-3.76.0-03}"
DOWNLOAD_URL="${2:-https://build-nexus.alauda.cn/repository/alauda/files/nexus-${NEXUS_VERSION}-unix.tar.gz}"
OUTPUT_FILE="${3:-upgrade-dependencies.sh}"

# Ignore list for packages that have special update logic
# Supports two formats:
#   - "groupId" - ignores all artifacts in the group
#   - "groupId:artifactId" - ignores specific artifact only
IGNORE_LIST=(
    # Add packages to ignore here, one per line
    # Example: "org.apache.commons:commons-compress" (specific artifact)
    # Example: "org.eclipse.jetty" (entire group)
    org.apache.tika:tika-core
    org.eclipse.jetty
)

# Get absolute path for output file before changing directories
if [[ "$OUTPUT_FILE" = /* ]]; then
    OUTPUT_PATH="$OUTPUT_FILE"
else
    OUTPUT_PATH="$(pwd)/$OUTPUT_FILE"
fi

TEMP_DIR="/tmp/nexus-analyze-$$"
mkdir -p "$TEMP_DIR"

echo "===================================="
echo "Nexus JAR Package Analyzer"
echo "===================================="
echo "Version: $NEXUS_VERSION"
echo "Download URL: $DOWNLOAD_URL"
echo "Output file: $OUTPUT_PATH"
echo "Temp directory: $TEMP_DIR"
echo ""

# Download the tar.gz file
echo "[1/4] Downloading Nexus package..."
curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/nexus.tar.gz"

# Extract the tar.gz file
echo "[2/4] Extracting Nexus package..."
cd "$TEMP_DIR"
tar xzf nexus.tar.gz

# Find the extracted directory
NEXUS_DIR=$(find . -maxdepth 1 -type d -name "nexus-*" | head -n 1)
if [ -z "$NEXUS_DIR" ]; then
    echo "Error: Could not find extracted nexus directory"
    exit 1
fi

echo "Found Nexus directory: $NEXUS_DIR"

# Analyze JAR files
echo "[3/4] Analyzing JAR files..."

# Clear existing file
> "$OUTPUT_PATH"

echo "#!/bin/bash" >> "$OUTPUT_PATH"
echo "set -e" >> "$OUTPUT_PATH"
echo "" >> "$OUTPUT_PATH"
echo 
echo "# Auto-generated script to update JAR versions in Nexus" >> "$OUTPUT_PATH"
echo "" >> "$OUTPUT_PATH"

# Find all JAR files and extract information
find "$NEXUS_DIR" -type f -name "*.jar" | sort | while read -r jar_file; do
    # Get relative path from nexus directory
    rel_path="${jar_file#$NEXUS_DIR/}"
    
    # Extract artifact information from path
    # Format: system/org/example/artifact/version/artifact-version.jar
    if [[ "$rel_path" =~ ^system/(.+)/([^/]+)/([^/]+)\.jar$ ]]; then
        path_prefix="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        
        # Extract groupId and artifactId
        # Remove version from path
        group_artifact="${path_prefix%/$version}"
        
        # Get the artifact name (last component)
        artifact_id="${group_artifact##*/}"
        
        # Get group path (everything before artifact)
        group_path="${group_artifact%/$artifact_id}"
        
        # Convert path separators to dots for groupId
        group_id="${group_path//\//.}"
        
        # Check if package is in ignore list
        # Supports both "groupId" and "groupId:artifactId" formats
        skip_package=false
        for ignored in "${IGNORE_LIST[@]}"; do
            # Check if it's a group-only pattern (no colon)
            if [[ "$ignored" != *:* ]] && [[ "$group_id" == "$ignored" ]]; then
                skip_package=true
                echo "# Skipping package (group ignored): $group_id:${artifact_id}" >> "$OUTPUT_PATH"
                break
            fi
            # Check if it's a full groupId:artifactId pattern
            if [[ "$group_id:${artifact_id}" == "$ignored" ]]; then
                skip_package=true
                echo "# Skipping package: $group_id:${artifact_id}" >> "$OUTPUT_PATH"
                break
            fi
        done
        
        # Skip if in ignore list
        if [ "$skip_package" = true ]; then
            continue
        fi
        
        # Convert artifact_id to uppercase for variable name
        artifact_id_upper=$(echo "$artifact_id" | tr '[:lower:]' '[:upper:]' | tr '-' '_' | tr '.' '_')
        
        echo "# renovate: datasource=maven depName=${artifact_id} lookupName=${group_id}:${artifact_id}" >> "$OUTPUT_PATH"
        echo "export ${artifact_id_upper}_NEW_VERSION=${version}" >> "$OUTPUT_PATH"
        echo "\$NEXUS_HOME/scripts/replace.sh \$NEXUS_HOME $group_path/${artifact_id} $version \${${artifact_id_upper}_NEW_VERSION}" >> "$OUTPUT_PATH"
        echo "" >> "$OUTPUT_PATH"
    
    # Handle lib directory JARs (format: lib/some-dir/artifact-version.jar or lib/artifact-version.jar)
    # Matches patterns like: artifact-1.0.0.jar, artifact-jdk15to18-1.78.1.jar, artifact.name-2.0.jar
    elif [[ "$rel_path" =~ ^lib/(.*/)?([^/]+)\.jar$ ]]; then
        lib_subdir="${BASH_REMATCH[1]}"
        jar_filename="${BASH_REMATCH[2]}"
        
        # Try to extract version from filename (look for pattern: -X.Y where X and Y are numbers)
        # Match the last occurrence of -digit.digit pattern
        if [[ "$jar_filename" =~ ^(.+)-([0-9]+(\.[0-9]+.*)?)$ ]]; then
            artifact_name="${BASH_REMATCH[1]}"
            version="${BASH_REMATCH[2]}"
        else
            # No version found in filename, skip this JAR
            echo "::no-version:$rel_path"
            continue
        fi
        
        # Try to extract groupId and artifactId from JAR's pom.properties
        # Look for META-INF/maven/*/*/pom.properties inside the JAR
        pom_props=$(unzip -p "$jar_file" 'META-INF/maven/*/*/pom.properties' 2>/dev/null | head -n 20)
        
        group_id=""
        artifact_id=""
        
        if [ -n "$pom_props" ]; then
            # Extract groupId and artifactId from pom.properties
            group_id=$(echo "$pom_props" | grep '^groupId=' | cut -d'=' -f2 | tr -d '\r\n[:space:]')
            artifact_id=$(echo "$pom_props" | grep '^artifactId=' | cut -d'=' -f2 | tr -d '\r\n[:space:]')
        fi
        
        # Convert artifact_name to uppercase for variable name
        artifact_name_upper=$(echo "$artifact_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_' | tr '.' '_')
        
        if [ -n "$group_id" ] && [ -n "$artifact_id" ]; then
            echo "# lib directory JAR: $artifact_name (detected: $group_id:$artifact_id)" >> "$OUTPUT_PATH"
            echo "# renovate: datasource=maven depName=${artifact_id} lookupName=${group_id}:${artifact_id}" >> "$OUTPUT_PATH"
            echo "export ${artifact_name_upper}_NEW_VERSION=${version}" >> "$OUTPUT_PATH"
            echo "\$NEXUS_HOME/scripts/replace-lib.sh \$NEXUS_HOME $group_id $artifact_id $version \${${artifact_name_upper}_NEW_VERSION}" >> "$OUTPUT_PATH"
        else
            echo "# Skip $artifact_name (groupId or artifactId not detected)" >> "$OUTPUT_PATH"
        fi
        echo "" >> "$OUTPUT_PATH"
    else
        # For JAR files not matching any known pattern
        echo "::unknown:$rel_path"
    fi
done

echo "[4/4] Analysis complete!"
echo ""
echo "Results written to: $OUTPUT_PATH"
echo "Total JAR files found: $(wc -l < "$OUTPUT_PATH")"
echo ""

# Show summary statistics
echo "Summary by directory:"
awk -F: '{print $4}' "$OUTPUT_PATH" | awk -F/ '{print $1}' | sort | uniq -c | sort -rn

# Cleanup
echo ""
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Done!"
