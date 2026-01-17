#!/bin/sh

# Script to replace JAR files in lib directory
# Unlike system directory, lib directory doesn't follow Maven layout (group/artifact/version)
# JARs are stored directly or in subdirectories with version in filename

# Check parameters
if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
    echo "Usage: $0 <NEXUS_HOME> <GROUP_ID> <ARTIFACT_ID> <OLD_VERSION> <NEW_VERSION> [JAR_URL]"
    echo "Example: $0 /opt/nexus org.apache.commons commons-compress 1.24.0 1.26.2"
    echo "Example with custom URL: $0 /opt/nexus org.apache.commons commons-compress 1.24.0 1.26.2 https://custom-repo.com/path/to/jar.jar"
    exit 1
fi

NEXUS_HOME="$1"
GROUP_ID="$2"
ARTIFACT_ID="$3"
OLD_VERSION="$4"
NEW_VERSION="$5"
JAR_URL="$6"

# For backward compatibility, also support JAR_NAME
JAR_NAME="$ARTIFACT_ID"

# Skip if versions are the same
if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
    echo "Skipping: OLD_VERSION and NEW_VERSION are the same ($OLD_VERSION)"
    exit 0
fi

OLD_JAR_FILENAME="$JAR_NAME-$OLD_VERSION.jar"
NEW_JAR_FILENAME="$JAR_NAME-$NEW_VERSION.jar"

# 1. Find old JAR file in lib directory
echo "Searching for old version JAR: $OLD_JAR_FILENAME..."
OLD_JAR_PATH=$(find "$NEXUS_HOME/lib" -type f -name "$OLD_JAR_FILENAME" 2>/dev/null | head -n 1)

if [ -z "$OLD_JAR_PATH" ]; then
    echo "Could not find $OLD_JAR_FILENAME in $NEXUS_HOME/lib, please verify the JAR name and version are correct"
    exit 0
fi

echo "Found old JAR at: $OLD_JAR_PATH"

# Get the directory where the old JAR is located
JAR_DIR=$(dirname "$OLD_JAR_PATH")
NEW_JAR_PATH="$JAR_DIR/$NEW_JAR_FILENAME"

# 2. Download new JAR to the same location
echo "Downloading new version JAR $NEW_JAR_FILENAME to $JAR_DIR..."

if [ -n "$JAR_URL" ]; then
    echo "Using custom URL: $JAR_URL"
    # Verify URL contains expected version to prevent user errors
    if ! echo "$JAR_URL" | grep -q "$NEW_VERSION"; then
        echo "Warning: Custom URL does not contain expected version $NEW_VERSION"
        echo "  URL: $JAR_URL"
        echo "  Expected version: $NEW_VERSION"
        echo "  Continuing anyway, but please verify the URL is correct..."
    fi
    curl -L -o "$NEW_JAR_PATH" "$JAR_URL"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download JAR from $JAR_URL"
        exit 1
    fi
else
    # Convert GROUP_ID dots to slashes for Maven Central path
    GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')
    MAVEN_URL="https://repo1.maven.org/maven2/$GROUP_PATH/$ARTIFACT_ID/$NEW_VERSION/$ARTIFACT_ID-$NEW_VERSION.jar"
    echo "Using Maven Central: $MAVEN_URL"
    curl -L -o "$NEW_JAR_PATH" "$MAVEN_URL"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download JAR from Maven Central"
        echo "  URL: $MAVEN_URL"
        exit 1
    fi
fi

# Verify downloaded file exists and is not empty
if [ ! -f "$NEW_JAR_PATH" ] || [ ! -s "$NEW_JAR_PATH" ]; then
    echo "Error: Downloaded JAR file is missing or empty: $NEW_JAR_PATH"
    exit 1
fi

echo "Successfully downloaded: $NEW_JAR_PATH"

# 3. Update version references in configuration files
echo "Updating configuration files..."

# Update bin/nexus
if [ -f "$NEXUS_HOME/bin/nexus" ]; then
    echo "Updating $NEXUS_HOME/bin/nexus..."
    sed -i "s|$OLD_JAR_FILENAME|$NEW_JAR_FILENAME|g" "$NEXUS_HOME/bin/nexus"
fi

# Update bin/nexus.vmoptions
if [ -f "$NEXUS_HOME/bin/nexus.vmoptions" ]; then
    echo "Updating $NEXUS_HOME/bin/nexus.vmoptions..."
    sed -i "s|$OLD_JAR_FILENAME|$NEW_JAR_FILENAME|g" "$NEXUS_HOME/bin/nexus.vmoptions"
fi

# 4. Remove old version JAR
echo "Removing old version JAR: $OLD_JAR_PATH..."
rm -f "$OLD_JAR_PATH"

if [ $? -eq 0 ]; then
    echo "Successfully removed old JAR"
else
    echo "Warning: Failed to remove old JAR at $OLD_JAR_PATH"
    echo "You may need to remove it manually"
fi

echo "Lib JAR replacement complete!"
echo "  Old: $OLD_JAR_FILENAME"
echo "  New: $NEW_JAR_FILENAME"
echo "  Location: $JAR_DIR"
