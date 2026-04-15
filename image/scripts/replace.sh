#!/bin/sh

set -e

# Check parameters
if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <NEXUS_HOME> <JAR_PATH> <OLD_VERSION> <NEW_VERSION> [JAR_URL]"
    echo "Example: $0 /opt/nexus org/apache/commons/commons-compress 1.24.0 1.26.2"
    echo "Example with custom URL: $0 /opt/nexus org/apache/commons/commons-compress 1.24.0 1.26.2 https://custom-repo.com/path/to/jar.jar"
    exit 1
fi

NEXUS_HOME="$1"
JAR_PATH="$2"
OLD_VERSION="$3"
NEW_VERSION="$4"
JAR_URL="$5"

JAR_NAME=$(basename $JAR_PATH)

# 1. Download new JAR
echo "Downloading new version JAR $JAR_NAME-$NEW_VERSION.jar..."
mkdir -p $NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION

# Use custom URL if provided, otherwise use Maven Central
if [ -n "$JAR_URL" ]; then
    echo "Using custom URL: $JAR_URL"
    # Verify URL contains expected version to prevent user errors
    if ! echo "$JAR_URL" | grep -q "$NEW_VERSION"; then
        echo "Warning: Custom URL does not contain expected version $NEW_VERSION"
        echo "  URL: $JAR_URL"
        echo "  Expected version: $NEW_VERSION"
        echo "  Continuing anyway, but please verify the URL is correct..."
    fi
    curl -L -o $NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar "$JAR_URL"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download JAR from $JAR_URL"
        exit 1
    fi
    # Verify downloaded file exists and is not empty
    JAR_FILE="$NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar"
    if [ ! -f "$JAR_FILE" ] || [ ! -s "$JAR_FILE" ]; then
        echo "Error: Downloaded JAR file is missing or empty: $JAR_FILE"
        exit 1
    fi
else
    echo "Using Maven Central: https://repo1.maven.org/maven2/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar"
    curl -L -o $NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar \
      https://repo1.maven.org/maven2/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar
fi
# 2. Update version references in configuration files
echo "Updating configuration files $JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION ..."
# Replace format 1: "commons-compress/1.24.0"
sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g" $NEXUS_HOME/etc/karaf/startup.properties
find $NEXUS_HOME/system/org/sonatype/nexus/assemblies -name "*.xml" | xargs sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g"
find $NEXUS_HOME/system/com/sonatype/nexus/assemblies -name "*.xml" | xargs sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g"

# Replace format 2: "commons-compress-1.24.0.jar"
sed -i "s|$JAR_NAME-$OLD_VERSION.jar|$JAR_NAME-$NEW_VERSION.jar|g" $NEXUS_HOME/etc/karaf/startup.properties

# 3. Remove old version JAR
echo "Removing old version JAR $JAR_PATH/$OLD_VERSION/$JAR_NAME-$OLD_VERSION.jar ..."
rm -rf $NEXUS_HOME/system/$JAR_PATH/$OLD_VERSION
