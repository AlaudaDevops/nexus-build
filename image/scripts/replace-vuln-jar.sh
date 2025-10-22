#!/bin/bash

# Script to replace dependencies in a Spring Boot JAR file and repackage it
# This script extracts the JAR, replaces specified dependencies, and repackages it

set -e

# Function to log messages
log() {
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message"
}

# Function to extract JAR file
extract_jar() {
    local jar_file="$1"
    local extract_dir="$2"
    
    log "=== Extracting JAR file: $jar_file ==="
    
    if [[ ! -f "$jar_file" ]]; then
        log "JAR file not found: $jar_file"
        exit 1
    fi
    
    # Get absolute path of JAR file before changing directory
    local jar_abs_path="$(realpath "$jar_file")"
    log "JAR absolute path: $jar_abs_path"
    
    echo "Extracting JAR file to directory: $extract_dir"
    mkdir -p "$extract_dir"
    cd "$extract_dir"
    
    # Extract the JAR file using absolute path
    jar xf "$jar_abs_path"
    
    if [[ $? -ne 0 ]]; then
        log "Failed to extract JAR file: $jar_file"
        exit 1
    fi
    
    log "JAR file extracted to: $extract_dir"
    if [[ "$VERBOSE" == "true" ]]; then
        tree -L 3 -a "$extract_dir"
    fi
}

# Function to record file order in JAR
record_jar_file_order() {
    local jar_file="$1"
    local temp_dir="$2"
    local filelist_path="$temp_dir/filelist.txt"
    
    log "=== Recording JAR file order ==="
    log "JAR file: $jar_file"
    log "File list will be saved to: $filelist_path"
    
    # Use unzip -l to list files and extract the file names (4th column)
    # Filter out empty lines and directories
    unzip -l "$jar_file" | awk '{print $4}' | grep -v "^$" > "$filelist_path"
    
    local file_count
    file_count=$(wc -l < "$filelist_path")
    log "Recorded $file_count files in order"
    
    if [[ "$VERBOSE" == "true" ]]; then
        log "First 10 files in order:"
        head -10 "$filelist_path" | while read line; do
            log "  $line"
        done
    fi
    
    echo "$filelist_path"
}

# Function to update index files (layers.idx and classpath.idx)
update_index_files() {
    local work_dir="$1"
    local jar_name="$2"
    local old_version="$3"
    local new_version="$4"
    
    log "Updating index files for $jar_name: $old_version -> $new_version"
    cd $work_dir

    # Update layers.idx file
    local layers_idx="BOOT-INF/layers.idx"
    if [[ -f "$layers_idx" ]]; then
        log "Updating layers.idx file"

        # Replace old version with new version in layers.idx
        sed -i "s|BOOT-INF/lib/$jar_name-$old_version.jar|BOOT-INF/lib/$jar_name-$new_version.jar|g" "$layers_idx"
        
        # Verify the change was made
        if grep -q "BOOT-INF/lib/$jar_name-$new_version.jar" "$layers_idx"; then
            log "Successfully updated layers.idx: $jar_name-$old_version.jar -> $jar_name-$new_version.jar"
        else
            log "Warning: Could not find entry to update in layers.idx for $jar_name-$old_version.jar"
        fi
    else
        log "Warning: layers.idx file not found"
    fi
    
    # Update classpath.idx file
    local classpath_idx="BOOT-INF/classpath.idx"
    if [[ -f "$classpath_idx" ]]; then
        log "Updating classpath.idx file"

        # Replace old version with new version in classpath.idx
        sed -i "s|BOOT-INF/lib/$jar_name-$old_version.jar|BOOT-INF/lib/$jar_name-$new_version.jar|g" "$classpath_idx"
        
        # Verify the change was made
        if grep -q "BOOT-INF/lib/$jar_name-$new_version.jar" "$classpath_idx"; then
            log "Successfully updated classpath.idx: $jar_name-$old_version.jar -> $jar_name-$new_version.jar"
        else
            log "Warning: Could not find entry to update in classpath.idx for $jar_name-$old_version.jar"
        fi
    else
        log "Warning: classpath.idx file not found"
    fi
}

# Function to find and replace dependency
replace_dependency() {
    local replace_jar_path="$1"
    local old_version="$2"
    local new_version="$3"
    local work_dir="$4"
    local replace_jar="$5"
    local filelist_path="$6"
    
    log "=== Replacing dependency: $replace_jar_path $old_version -> $new_version ==="
    
    # Extract artifact name from the path (e.g., commons-beanutils/commons-beanutils -> commons-beanutils)
    local jar_name=$(basename $replace_jar_path)
    local old_jar_path=$work_dir/BOOT-INF/lib/$jar_name-$old_version.jar
    local new_jar_path=$work_dir/BOOT-INF/lib/$jar_name-$new_version.jar

    if [[ -f "$old_jar_path" ]]; then
        log "Old version jar found: $old_jar_path"
        # Remove old version JAR
        rm -f "$old_jar_path"
    else
        log "Old version jar not found: $old_jar_path"
        log "Available jars in BOOT-INF/lib:"
        log "Skipping replacement for $replace_jar_path as old version not found"
        return 0
    fi
    
    if [[ -n "$replace_jar" && -f "$replace_jar" ]]; then
        log "Using local jar: $replace_jar"
        ls -la $replace_jar
        cp $replace_jar $work_dir/BOOT-INF/lib/$jar_name-$new_version.jar
        ls -la $work_dir/BOOT-INF/lib/$jar_name-$new_version.jar
    else
        log "Downloading new version from Maven Central: $replace_jar_path/$new_version/$jar_name-$new_version.jar"
        curl -L -o $new_jar_path \
            https://repo1.maven.org/maven2/$replace_jar_path/$new_version/$jar_name-$new_version.jar
    
        if [[ ! -f "$new_jar_path" ]] || [[ ! -s "$new_jar_path" ]]; then
            log "Failed to download new version jar: $jar_name-$new_version.jar"
            exit 1
        fi
    fi
    
    # Validate downloaded JAR file
    if ! jar tf "$new_jar_path" > /dev/null 2>&1; then
        log "Downloaded file is not a valid JAR: $new_jar_path"
        rm -f "$new_jar_path"
        exit 1
    fi
    
    log "Update new version jar: $new_jar_path"

    # Update index files
    update_index_files "$work_dir" "$jar_name" "$old_version" "$new_version"

    sed -i "s|$jar_name-$old_version.jar|$jar_name-$new_version.jar|g" "$filelist_path"
    
    log "Successfully replaced dependency: $old_version -> $new_version"
}

function print_usage() {
    echo "Usage: $0 -i <BOOT_JAR_PATH> -r <REPLACE_JAR_PATH>:<OLD_VERSION>:<NEW_VERSION>"
    echo "Example: $0 -i app.jar -r commons-beanutils/commons-beanutils:1.9.4:1.11.0,commons-fileupload:commons-fileupload:1.5:1.6.0"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input-jar)
            ORIGINAL_JAR="$2"
            shift 2
            ;;
        -r|--replace-jar-info)
            REPLACE_JAR_INFO="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            log "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done


# Get the current working directory where the script is executed
EXECUTION_DIR=$(mktemp -d)

ORIGINAL_JAR="$(realpath "$ORIGINAL_JAR")"

# Validate required parameters
if [[ -z "$ORIGINAL_JAR" || -z "$REPLACE_JAR_INFO" ]]; then
    log "Missing required parameters"
    print_usage
    exit 1
fi


# Main execution
log "Starting JAR dependency replacement process..."
log "Current working directory: $EXECUTION_DIR"
log "Original JAR path: $ORIGINAL_JAR"

record_jar_file_order "$ORIGINAL_JAR" "$EXECUTION_DIR"
filelist_path="$EXECUTION_DIR/filelist.txt"

# Extract the original JAR
extract_jar "$ORIGINAL_JAR" "$EXECUTION_DIR"

for replace_jar_info in $(echo $REPLACE_JAR_INFO | tr ',' '\n'); do
    replace_jar_path=$(echo $replace_jar_info | cut -d':' -f1)
    old_version=$(echo $replace_jar_info | cut -d':' -f2)
    new_version=$(echo $replace_jar_info | cut -d':' -f3)
    local_jar=$(echo $replace_jar_info | cut -d':' -f4)
    replace_dependency "$replace_jar_path" "$old_version" "$new_version" "$EXECUTION_DIR" "$local_jar" "$filelist_path"
done

log "Repackaging JAR file..."
mv $ORIGINAL_JAR "$ORIGINAL_JAR.bak"
cd "$EXECUTION_DIR"
echo $filelist_path
zip -r -0 "$ORIGINAL_JAR" -@ < "$EXECUTION_DIR/filelist.txt"

log "JAR dependency replacement completed successfully!"
log "Original JAR: $ORIGINAL_JAR"
log "Replaced dependencies: " 
for replace_jar_info in $(echo $REPLACE_JAR_INFO | tr ',' '\n'); do
    replace_jar_path=$(echo $replace_jar_info | cut -d':' -f1)
    old_version=$(echo $replace_jar_info | cut -d':' -f2)
    new_version=$(echo $replace_jar_info | cut -d':' -f3)
    local_jar=$(echo $replace_jar_info | cut -d':' -f4)
    log "   $replace_jar_path: $old_version -> $new_version (local: $local_jar)"
done

echo "Cleaning up temporary files..."
cd $EXECUTION_DIR
rm -rf BOOT-INF META-INF org $filelist_path
