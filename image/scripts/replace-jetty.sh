#!/bin/sh

NEXUS_HOME=$1
OLD_VERSION=$2
NEW_VERSION=$3

# upgrade jetty jar
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-server ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-http ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-server ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-client ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-continuation ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-deploy ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-io ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-jmx ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-proxy ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-rewrite ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-security ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-servlet ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-util ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-util-ajax ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-webapp ${OLD_VERSION} ${NEW_VERSION}
${NEXUS_HOME}/scripts/replace.sh ${NEXUS_HOME} org/eclipse/jetty/jetty-xml ${OLD_VERSION} ${NEW_VERSION}

set -x
echo "Jetty jars replaced from ${OLD_VERSION} to ${NEW_VERSION}"
# cleanup generated files
rm ${NEXUS_HOME}/system/generated/*

# repackage jetty-util
cp ${NEXUS_HOME}/system/org/eclipse/jetty/jetty-util/${NEW_VERSION}/jetty-util-${NEW_VERSION}.jar ${NEXUS_HOME}/system/generated/wrap_mvn_org.eclipse.jetty_jetty-util_${NEW_VERSION}_overwrite_merge_Import-Package_org.slf4j_

sed -i "s|wrap_mvn_org.eclipse.jetty_jetty-util_${OLD_VERSION}_overwrite_merge_Import-Package_org.slf4j_|wrap_mvn_org.eclipse.jetty_jetty-util_${NEW_VERSION}_overwrite_merge_Import-Package_org.slf4j_|g" $NEXUS_HOME/etc/karaf/startup.properties
