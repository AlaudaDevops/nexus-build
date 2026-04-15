#!/bin/sh
set -e

# This script is used to replace the vulnerable nexus jar packages with the patched ones in the image build process.
NEXUS_VERSION=${1:-3.76.0-03}

cp /tmp/jar/nexus-ui-plugin-${NEXUS_VERSION}.jar ${NEXUS_HOME}/system/org/sonatype/nexus/nexus-ui-plugin/${NEXUS_VERSION}/nexus-ui-plugin-${NEXUS_VERSION}.jar
cp /tmp/jar/nexus-rapture-${NEXUS_VERSION}.jar ${NEXUS_HOME}/system/org/sonatype/nexus/nexus-rapture/${NEXUS_VERSION}/nexus-rapture-${NEXUS_VERSION}.jar
cp /tmp/jar/nexus-coreui-plugin-${NEXUS_VERSION}.jar  ${NEXUS_HOME}/system/org/sonatype/nexus/plugins/nexus-coreui-plugin/${NEXUS_VERSION}/nexus-coreui-plugin-${NEXUS_VERSION}.jar

# Install SwaggerAccessFilter: block unauthenticated access to Swagger API docs (DEVOPS-43719)
cp /tmp/jar/swagger-access-filter.jar ${NEXUS_HOME}/lib/boot/swagger-access-filter.jar
sed -i '/<filter>/i \
  <filter>\
    <filter-name>swaggerAccessFilter</filter-name>\
    <filter-class>org.sonatype.nexus.security.SwaggerAccessFilter</filter-class>\
  </filter>\
  <filter-mapping>\
    <filter-name>swaggerAccessFilter</filter-name>\
    <url-pattern>/service/rest/swagger.json</url-pattern>\
    <url-pattern>/service/rest/swagger.yaml</url-pattern>\
  </filter-mapping>\
' ${NEXUS_HOME}/etc/jetty/nexus-web.xml
sed -i 's|<Set name="throwUnavailableOnStartupException">true</Set>|<Set name="throwUnavailableOnStartupException">true</Set>\n        <Set name="extraClasspath"><Property name="karaf.base"/>/lib/boot/swagger-access-filter.jar</Set>|' ${NEXUS_HOME}/etc/jetty/jetty.xml

rm -rf /tmp/jar/
