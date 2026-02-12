#!/bin/sh
set -e

# This script is used to replace the vulnerable nexus jar packages with the patched ones in the image build process.
NEXUS_VERSION=${1:-3.76.0-03}

cp /tmp/jar/nexus-ui-plugin-${NEXUS_VERSION}.jar ${NEXUS_HOME}/system/org/sonatype/nexus/nexus-ui-plugin/${NEXUS_VERSION}/nexus-ui-plugin-${NEXUS_VERSION}.jar
cp /tmp/jar/nexus-rapture-${NEXUS_VERSION}.jar ${NEXUS_HOME}/system/org/sonatype/nexus/nexus-rapture/${NEXUS_VERSION}/nexus-rapture-${NEXUS_VERSION}.jar
cp /tmp/jar/nexus-coreui-plugin-${NEXUS_VERSION}.jar  ${NEXUS_HOME}/system/org/sonatype/nexus/plugins/nexus-coreui-plugin/${NEXUS_VERSION}/nexus-coreui-plugin-${NEXUS_VERSION}.jar

rm -rf /tmp/jar/
