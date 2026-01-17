#!/bin/bash
set -e

# Auto-generated script to update JAR versions in Nexus

# Skip bcpg-jdk15to18 (groupId or artifactId not detected)

# Skip bcpkix-jdk15to18 (groupId or artifactId not detected)

# Skip bcprov-jdk15to18 (groupId or artifactId not detected)

# Skip bcutil-jdk15to18 (groupId or artifactId not detected)

# Skip activation (groupId or artifactId not detected)

# lib directory JAR: istack-commons-runtime (detected: com.sun.istack:istack-commons-runtime)
# renovate: datasource=maven depName=istack-commons-runtime lookupName=com.sun.istack:istack-commons-runtime
export ISTACK_COMMONS_RUNTIME_NEW_VERSION=3.0.10
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME com.sun.istack istack-commons-runtime 3.0.10 ${ISTACK_COMMONS_RUNTIME_NEW_VERSION}

# lib directory JAR: jakarta.xml.bind-api (detected: jakarta.xml.bind:jakarta.xml.bind-api)
# renovate: datasource=maven depName=jakarta.xml.bind-api lookupName=jakarta.xml.bind:jakarta.xml.bind-api
export JAKARTA_XML_BIND_API_NEW_VERSION=2.3.3
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME jakarta.xml.bind jakarta.xml.bind-api 2.3.3 ${JAKARTA_XML_BIND_API_NEW_VERSION}

# lib directory JAR: jaxb-runtime (detected: org.glassfish.jaxb:jaxb-runtime)
# renovate: datasource=maven depName=jaxb-runtime lookupName=org.glassfish.jaxb:jaxb-runtime
export JAXB_RUNTIME_NEW_VERSION=2.3.3
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.glassfish.jaxb jaxb-runtime 2.3.3 ${JAXB_RUNTIME_NEW_VERSION}

# lib directory JAR: org.apache.karaf.diagnostic.boot (detected: org.apache.karaf.diagnostic:org.apache.karaf.diagnostic.boot)
# renovate: datasource=maven depName=org.apache.karaf.diagnostic.boot lookupName=org.apache.karaf.diagnostic:org.apache.karaf.diagnostic.boot
export ORG_APACHE_KARAF_DIAGNOSTIC_BOOT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf.diagnostic org.apache.karaf.diagnostic.boot 4.3.9 ${ORG_APACHE_KARAF_DIAGNOSTIC_BOOT_NEW_VERSION}

# lib directory JAR: org.apache.karaf.jaas.boot (detected: org.apache.karaf.jaas:org.apache.karaf.jaas.boot)
# renovate: datasource=maven depName=org.apache.karaf.jaas.boot lookupName=org.apache.karaf.jaas:org.apache.karaf.jaas.boot
export ORG_APACHE_KARAF_JAAS_BOOT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf.jaas org.apache.karaf.jaas.boot 4.3.9 ${ORG_APACHE_KARAF_JAAS_BOOT_NEW_VERSION}

# lib directory JAR: org.apache.karaf.main (detected: org.apache.karaf:org.apache.karaf.main)
# renovate: datasource=maven depName=org.apache.karaf.main lookupName=org.apache.karaf:org.apache.karaf.main
export ORG_APACHE_KARAF_MAIN_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf org.apache.karaf.main 4.3.9 ${ORG_APACHE_KARAF_MAIN_NEW_VERSION}

# lib directory JAR: org.apache.karaf.specs.activator (detected: org.apache.karaf.specs:org.apache.karaf.specs.activator)
# renovate: datasource=maven depName=org.apache.karaf.specs.activator lookupName=org.apache.karaf.specs:org.apache.karaf.specs.activator
export ORG_APACHE_KARAF_SPECS_ACTIVATOR_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf.specs org.apache.karaf.specs.activator 4.3.9 ${ORG_APACHE_KARAF_SPECS_ACTIVATOR_NEW_VERSION}

# lib directory JAR: osgi.core (detected: org.osgi:osgi.core)
# renovate: datasource=maven depName=osgi.core lookupName=org.osgi:osgi.core
export OSGI_CORE_NEW_VERSION=7.0.0
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.osgi osgi.core 7.0.0 ${OSGI_CORE_NEW_VERSION}

# lib directory JAR: txw2 (detected: org.glassfish.jaxb:txw2)
# renovate: datasource=maven depName=txw2 lookupName=org.glassfish.jaxb:txw2
export TXW2_NEW_VERSION=2.3.3
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.glassfish.jaxb txw2 2.3.3 ${TXW2_NEW_VERSION}

# lib directory JAR: org.apache.karaf.specs.java.xml (detected: org.apache.karaf.specs:org.apache.karaf.specs.java.xml)
# renovate: datasource=maven depName=org.apache.karaf.specs.java.xml lookupName=org.apache.karaf.specs:org.apache.karaf.specs.java.xml
export ORG_APACHE_KARAF_SPECS_JAVA_XML_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf.specs org.apache.karaf.specs.java.xml 4.3.9 ${ORG_APACHE_KARAF_SPECS_JAVA_XML_NEW_VERSION}

# lib directory JAR: org.apache.karaf.specs.locator (detected: org.apache.karaf.specs:org.apache.karaf.specs.locator)
# renovate: datasource=maven depName=org.apache.karaf.specs.locator lookupName=org.apache.karaf.specs:org.apache.karaf.specs.locator
export ORG_APACHE_KARAF_SPECS_LOCATOR_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME org.apache.karaf.specs org.apache.karaf.specs.locator 4.3.9 ${ORG_APACHE_KARAF_SPECS_LOCATOR_NEW_VERSION}

# lib directory JAR: error_prone_annotations (detected: com.google.errorprone:error_prone_annotations)
# renovate: datasource=maven depName=error_prone_annotations lookupName=com.google.errorprone:error_prone_annotations
export ERROR_PRONE_ANNOTATIONS_NEW_VERSION=2.21.1
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME com.google.errorprone error_prone_annotations 2.21.1 ${ERROR_PRONE_ANNOTATIONS_NEW_VERSION}

# lib directory JAR: javax.annotation-api (detected: javax.annotation:javax.annotation-api)
# renovate: datasource=maven depName=javax.annotation-api lookupName=javax.annotation:javax.annotation-api
export JAVAX_ANNOTATION_API_NEW_VERSION=1.2
$NEXUS_HOME/scripts/replace-lib.sh $NEXUS_HOME javax.annotation javax.annotation-api 1.2 ${JAVAX_ANNOTATION_API_NEW_VERSION}

# Skip jsr305 (groupId or artifactId not detected)

# renovate: datasource=maven depName=atlassian-crowd-rest-client lookupName=com.atlassian.crowd.client:atlassian-crowd-rest-client
export ATLASSIAN_CROWD_REST_CLIENT_NEW_VERSION=1.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/atlassian/crowd/client/atlassian-crowd-rest-client 1.1 ${ATLASSIAN_CROWD_REST_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=java-jwt lookupName=com.auth0:java-jwt
export JAVA_JWT_NEW_VERSION=3.16.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/auth0/java-jwt 3.16.0 ${JAVA_JWT_NEW_VERSION}

# renovate: datasource=maven depName=itu lookupName=com.ethlo.time:itu
export ITU_NEW_VERSION=1.7.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/ethlo/time/itu 1.7.0 ${ITU_NEW_VERSION}

# renovate: datasource=maven depName=classmate lookupName=com.fasterxml:classmate
export CLASSMATE_NEW_VERSION=1.5.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/classmate 1.5.1 ${CLASSMATE_NEW_VERSION}

# renovate: datasource=maven depName=jackson-annotations lookupName=com.fasterxml.jackson.core:jackson-annotations
export JACKSON_ANNOTATIONS_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/core/jackson-annotations 2.17.0 ${JACKSON_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=jackson-core lookupName=com.fasterxml.jackson.core:jackson-core
export JACKSON_CORE_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/core/jackson-core 2.17.0 ${JACKSON_CORE_NEW_VERSION}

# renovate: datasource=maven depName=jackson-databind lookupName=com.fasterxml.jackson.core:jackson-databind
export JACKSON_DATABIND_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/core/jackson-databind 2.17.0 ${JACKSON_DATABIND_NEW_VERSION}

# renovate: datasource=maven depName=jackson-dataformat-cbor lookupName=com.fasterxml.jackson.dataformat:jackson-dataformat-cbor
export JACKSON_DATAFORMAT_CBOR_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/dataformat/jackson-dataformat-cbor 2.17.0 ${JACKSON_DATAFORMAT_CBOR_NEW_VERSION}

# renovate: datasource=maven depName=jackson-dataformat-smile lookupName=com.fasterxml.jackson.dataformat:jackson-dataformat-smile
export JACKSON_DATAFORMAT_SMILE_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/dataformat/jackson-dataformat-smile 2.17.0 ${JACKSON_DATAFORMAT_SMILE_NEW_VERSION}

# renovate: datasource=maven depName=jackson-dataformat-toml lookupName=com.fasterxml.jackson.dataformat:jackson-dataformat-toml
export JACKSON_DATAFORMAT_TOML_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/dataformat/jackson-dataformat-toml 2.17.0 ${JACKSON_DATAFORMAT_TOML_NEW_VERSION}

# renovate: datasource=maven depName=jackson-dataformat-xml lookupName=com.fasterxml.jackson.dataformat:jackson-dataformat-xml
export JACKSON_DATAFORMAT_XML_NEW_VERSION=2.14.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/dataformat/jackson-dataformat-xml 2.14.2 ${JACKSON_DATAFORMAT_XML_NEW_VERSION}

# renovate: datasource=maven depName=jackson-dataformat-yaml lookupName=com.fasterxml.jackson.dataformat:jackson-dataformat-yaml
export JACKSON_DATAFORMAT_YAML_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/dataformat/jackson-dataformat-yaml 2.17.0 ${JACKSON_DATAFORMAT_YAML_NEW_VERSION}

# renovate: datasource=maven depName=jackson-datatype-jdk8 lookupName=com.fasterxml.jackson.datatype:jackson-datatype-jdk8
export JACKSON_DATATYPE_JDK8_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/datatype/jackson-datatype-jdk8 2.17.0 ${JACKSON_DATATYPE_JDK8_NEW_VERSION}

# renovate: datasource=maven depName=jackson-datatype-joda lookupName=com.fasterxml.jackson.datatype:jackson-datatype-joda
export JACKSON_DATATYPE_JODA_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/datatype/jackson-datatype-joda 2.17.0 ${JACKSON_DATATYPE_JODA_NEW_VERSION}

# renovate: datasource=maven depName=jackson-datatype-jsr310 lookupName=com.fasterxml.jackson.datatype:jackson-datatype-jsr310
export JACKSON_DATATYPE_JSR310_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/datatype/jackson-datatype-jsr310 2.17.0 ${JACKSON_DATATYPE_JSR310_NEW_VERSION}

# renovate: datasource=maven depName=jackson-jaxrs-base lookupName=com.fasterxml.jackson.jaxrs:jackson-jaxrs-base
export JACKSON_JAXRS_BASE_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/jaxrs/jackson-jaxrs-base 2.17.0 ${JACKSON_JAXRS_BASE_NEW_VERSION}

# renovate: datasource=maven depName=jackson-jaxrs-json-provider lookupName=com.fasterxml.jackson.jaxrs:jackson-jaxrs-json-provider
export JACKSON_JAXRS_JSON_PROVIDER_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/jaxrs/jackson-jaxrs-json-provider 2.17.0 ${JACKSON_JAXRS_JSON_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=jackson-jaxrs-smile-provider lookupName=com.fasterxml.jackson.jaxrs:jackson-jaxrs-smile-provider
export JACKSON_JAXRS_SMILE_PROVIDER_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/jaxrs/jackson-jaxrs-smile-provider 2.17.0 ${JACKSON_JAXRS_SMILE_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=jackson-module-jaxb-annotations lookupName=com.fasterxml.jackson.module:jackson-module-jaxb-annotations
export JACKSON_MODULE_JAXB_ANNOTATIONS_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/module/jackson-module-jaxb-annotations 2.17.0 ${JACKSON_MODULE_JAXB_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=jackson-module-parameter-names lookupName=com.fasterxml.jackson.module:jackson-module-parameter-names
export JACKSON_MODULE_PARAMETER_NAMES_NEW_VERSION=2.17.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/fasterxml/jackson/module/jackson-module-parameter-names 2.17.0 ${JACKSON_MODULE_PARAMETER_NAMES_NEW_VERSION}

# renovate: datasource=maven depName=btf lookupName=com.github.fge:btf
export BTF_NEW_VERSION=1.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/fge/btf 1.2 ${BTF_NEW_VERSION}

# renovate: datasource=maven depName=jackson-coreutils lookupName=com.github.fge:jackson-coreutils
export JACKSON_COREUTILS_NEW_VERSION=1.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/fge/jackson-coreutils 1.6 ${JACKSON_COREUTILS_NEW_VERSION}

# renovate: datasource=maven depName=json-patch lookupName=com.github.fge:json-patch
export JSON_PATCH_NEW_VERSION=1.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/fge/json-patch 1.9 ${JSON_PATCH_NEW_VERSION}

# renovate: datasource=maven depName=msg-simple lookupName=com.github.fge:msg-simple
export MSG_SIMPLE_NEW_VERSION=1.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/fge/msg-simple 1.1 ${MSG_SIMPLE_NEW_VERSION}

# renovate: datasource=maven depName=zstd-jni lookupName=com.github.luben:zstd-jni
export ZSTD_JNI_NEW_VERSION=1.5.2-1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/luben/zstd-jni 1.5.2-1 ${ZSTD_JNI_NEW_VERSION}

# renovate: datasource=maven depName=packageurl-java lookupName=com.github.package-url:packageurl-java
export PACKAGEURL_JAVA_NEW_VERSION=1.4.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/package-url/packageurl-java 1.4.1 ${PACKAGEURL_JAVA_NEW_VERSION}

# renovate: datasource=maven depName=jcip-annotations lookupName=com.github.stephenc.jcip:jcip-annotations
export JCIP_ANNOTATIONS_NEW_VERSION=1.0-1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/stephenc/jcip/jcip-annotations 1.0-1 ${JCIP_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=java-semver lookupName=com.github.zafarkhaja:java-semver
export JAVA_SEMVER_NEW_VERSION=0.9.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/github/zafarkhaja/java-semver 0.9.0 ${JAVA_SEMVER_NEW_VERSION}

# renovate: datasource=maven depName=google-api-client lookupName=com.google.api-client:google-api-client
export GOOGLE_API_CLIENT_NEW_VERSION=2.4.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api-client/google-api-client 2.4.0 ${GOOGLE_API_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=api-common lookupName=com.google.api:api-common
export API_COMMON_NEW_VERSION=2.31.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/api-common 2.31.1 ${API_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=gax-grpc lookupName=com.google.api:gax-grpc
export GAX_GRPC_NEW_VERSION=2.48.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/gax-grpc 2.48.1 ${GAX_GRPC_NEW_VERSION}

# renovate: datasource=maven depName=gax-httpjson lookupName=com.google.api:gax-httpjson
export GAX_HTTPJSON_NEW_VERSION=2.48.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/gax-httpjson 2.48.1 ${GAX_HTTPJSON_NEW_VERSION}

# renovate: datasource=maven depName=gax lookupName=com.google.api:gax
export GAX_NEW_VERSION=2.48.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/gax 2.48.1 ${GAX_NEW_VERSION}

# renovate: datasource=maven depName=gapic-google-cloud-storage-v2 lookupName=com.google.api.grpc:gapic-google-cloud-storage-v2
export GAPIC_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION=2.39.0-alpha
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/gapic-google-cloud-storage-v2 2.39.0-alpha ${GAPIC_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION}

# renovate: datasource=maven depName=grpc-google-cloud-datastore-admin-v1 lookupName=com.google.api.grpc:grpc-google-cloud-datastore-admin-v1
export GRPC_GOOGLE_CLOUD_DATASTORE_ADMIN_V1_NEW_VERSION=2.20.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/grpc-google-cloud-datastore-admin-v1 2.20.1 ${GRPC_GOOGLE_CLOUD_DATASTORE_ADMIN_V1_NEW_VERSION}

# renovate: datasource=maven depName=grpc-google-cloud-storage-v2 lookupName=com.google.api.grpc:grpc-google-cloud-storage-v2
export GRPC_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION=2.39.0-alpha
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/grpc-google-cloud-storage-v2 2.39.0-alpha ${GRPC_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION}

# renovate: datasource=maven depName=proto-google-cloud-datastore-admin-v1 lookupName=com.google.api.grpc:proto-google-cloud-datastore-admin-v1
export PROTO_GOOGLE_CLOUD_DATASTORE_ADMIN_V1_NEW_VERSION=2.20.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/proto-google-cloud-datastore-admin-v1 2.20.1 ${PROTO_GOOGLE_CLOUD_DATASTORE_ADMIN_V1_NEW_VERSION}

# renovate: datasource=maven depName=proto-google-cloud-datastore-v1 lookupName=com.google.api.grpc:proto-google-cloud-datastore-v1
export PROTO_GOOGLE_CLOUD_DATASTORE_V1_NEW_VERSION=0.111.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/proto-google-cloud-datastore-v1 0.111.1 ${PROTO_GOOGLE_CLOUD_DATASTORE_V1_NEW_VERSION}

# renovate: datasource=maven depName=proto-google-cloud-storage-v2 lookupName=com.google.api.grpc:proto-google-cloud-storage-v2
export PROTO_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION=2.39.0-alpha
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/proto-google-cloud-storage-v2 2.39.0-alpha ${PROTO_GOOGLE_CLOUD_STORAGE_V2_NEW_VERSION}

# renovate: datasource=maven depName=proto-google-common-protos lookupName=com.google.api.grpc:proto-google-common-protos
export PROTO_GOOGLE_COMMON_PROTOS_NEW_VERSION=2.39.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/proto-google-common-protos 2.39.1 ${PROTO_GOOGLE_COMMON_PROTOS_NEW_VERSION}

# renovate: datasource=maven depName=proto-google-iam-v1 lookupName=com.google.api.grpc:proto-google-iam-v1
export PROTO_GOOGLE_IAM_V1_NEW_VERSION=1.34.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/api/grpc/proto-google-iam-v1 1.34.1 ${PROTO_GOOGLE_IAM_V1_NEW_VERSION}

# renovate: datasource=maven depName=google-api-services-storage lookupName=com.google.apis:google-api-services-storage
export GOOGLE_API_SERVICES_STORAGE_NEW_VERSION=v1-rev20240319-2.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/apis/google-api-services-storage v1-rev20240319-2.0.0 ${GOOGLE_API_SERVICES_STORAGE_NEW_VERSION}

# renovate: datasource=maven depName=google-auth-library-credentials lookupName=com.google.auth:google-auth-library-credentials
export GOOGLE_AUTH_LIBRARY_CREDENTIALS_NEW_VERSION=1.23.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/auth/google-auth-library-credentials 1.23.0 ${GOOGLE_AUTH_LIBRARY_CREDENTIALS_NEW_VERSION}

# renovate: datasource=maven depName=google-auth-library-oauth2-http lookupName=com.google.auth:google-auth-library-oauth2-http
export GOOGLE_AUTH_LIBRARY_OAUTH2_HTTP_NEW_VERSION=1.23.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/auth/google-auth-library-oauth2-http 1.23.0 ${GOOGLE_AUTH_LIBRARY_OAUTH2_HTTP_NEW_VERSION}

# renovate: datasource=maven depName=auto-value-annotations lookupName=com.google.auto.value:auto-value-annotations
export AUTO_VALUE_ANNOTATIONS_NEW_VERSION=1.10.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/auto/value/auto-value-annotations 1.10.4 ${AUTO_VALUE_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=datastore-v1-proto-client lookupName=com.google.cloud.datastore:datastore-v1-proto-client
export DATASTORE_V1_PROTO_CLIENT_NEW_VERSION=2.20.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/datastore/datastore-v1-proto-client 2.20.1 ${DATASTORE_V1_PROTO_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=google-cloud-core-grpc lookupName=com.google.cloud:google-cloud-core-grpc
export GOOGLE_CLOUD_CORE_GRPC_NEW_VERSION=2.38.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/google-cloud-core-grpc 2.38.1 ${GOOGLE_CLOUD_CORE_GRPC_NEW_VERSION}

# renovate: datasource=maven depName=google-cloud-core-http lookupName=com.google.cloud:google-cloud-core-http
export GOOGLE_CLOUD_CORE_HTTP_NEW_VERSION=2.38.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/google-cloud-core-http 2.38.1 ${GOOGLE_CLOUD_CORE_HTTP_NEW_VERSION}

# renovate: datasource=maven depName=google-cloud-core lookupName=com.google.cloud:google-cloud-core
export GOOGLE_CLOUD_CORE_NEW_VERSION=2.38.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/google-cloud-core 2.38.1 ${GOOGLE_CLOUD_CORE_NEW_VERSION}

# renovate: datasource=maven depName=google-cloud-datastore lookupName=com.google.cloud:google-cloud-datastore
export GOOGLE_CLOUD_DATASTORE_NEW_VERSION=2.20.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/google-cloud-datastore 2.20.1 ${GOOGLE_CLOUD_DATASTORE_NEW_VERSION}

# renovate: datasource=maven depName=google-cloud-storage lookupName=com.google.cloud:google-cloud-storage
export GOOGLE_CLOUD_STORAGE_NEW_VERSION=2.39.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/cloud/google-cloud-storage 2.39.0 ${GOOGLE_CLOUD_STORAGE_NEW_VERSION}

# renovate: datasource=maven depName=gson lookupName=com.google.code.gson:gson
export GSON_NEW_VERSION=2.9.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/code/gson/gson 2.9.0 ${GSON_NEW_VERSION}

# renovate: datasource=maven depName=error_prone_annotations lookupName=com.google.errorprone:error_prone_annotations
export ERROR_PRONE_ANNOTATIONS_NEW_VERSION=2.21.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/errorprone/error_prone_annotations 2.21.1 ${ERROR_PRONE_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=failureaccess lookupName=com.google.guava:failureaccess
export FAILUREACCESS_NEW_VERSION=1.0.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/guava/failureaccess 1.0.1 ${FAILUREACCESS_NEW_VERSION}

# renovate: datasource=maven depName=failureaccess lookupName=com.google.guava:failureaccess
export FAILUREACCESS_NEW_VERSION=1.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/guava/failureaccess 1.0.2 ${FAILUREACCESS_NEW_VERSION}

# renovate: datasource=maven depName=guava lookupName=com.google.guava:guava
export GUAVA_NEW_VERSION=32.1.2-jre
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/guava/guava 32.1.2-jre ${GUAVA_NEW_VERSION}

# renovate: datasource=maven depName=listenablefuture lookupName=com.google.guava:listenablefuture
export LISTENABLEFUTURE_NEW_VERSION=9999.0-empty-to-avoid-conflict-with-guava
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/guava/listenablefuture 9999.0-empty-to-avoid-conflict-with-guava ${LISTENABLEFUTURE_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client-apache-v2 lookupName=com.google.http-client:google-http-client-apache-v2
export GOOGLE_HTTP_CLIENT_APACHE_V2_NEW_VERSION=1.44.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client-apache-v2 1.44.1 ${GOOGLE_HTTP_CLIENT_APACHE_V2_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client-appengine lookupName=com.google.http-client:google-http-client-appengine
export GOOGLE_HTTP_CLIENT_APPENGINE_NEW_VERSION=1.44.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client-appengine 1.44.1 ${GOOGLE_HTTP_CLIENT_APPENGINE_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client-gson lookupName=com.google.http-client:google-http-client-gson
export GOOGLE_HTTP_CLIENT_GSON_NEW_VERSION=1.44.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client-gson 1.44.1 ${GOOGLE_HTTP_CLIENT_GSON_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client-jackson2 lookupName=com.google.http-client:google-http-client-jackson2
export GOOGLE_HTTP_CLIENT_JACKSON2_NEW_VERSION=1.44.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client-jackson2 1.44.1 ${GOOGLE_HTTP_CLIENT_JACKSON2_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client-protobuf lookupName=com.google.http-client:google-http-client-protobuf
export GOOGLE_HTTP_CLIENT_PROTOBUF_NEW_VERSION=1.44.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client-protobuf 1.44.2 ${GOOGLE_HTTP_CLIENT_PROTOBUF_NEW_VERSION}

# renovate: datasource=maven depName=google-http-client lookupName=com.google.http-client:google-http-client
export GOOGLE_HTTP_CLIENT_NEW_VERSION=1.44.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/http-client/google-http-client 1.44.1 ${GOOGLE_HTTP_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=guice-assistedinject lookupName=com.google.inject.extensions:guice-assistedinject
export GUICE_ASSISTEDINJECT_NEW_VERSION=6.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/inject/extensions/guice-assistedinject 6.0.0 ${GUICE_ASSISTEDINJECT_NEW_VERSION}

# renovate: datasource=maven depName=guice-servlet lookupName=com.google.inject.extensions:guice-servlet
export GUICE_SERVLET_NEW_VERSION=6.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/inject/extensions/guice-servlet 6.0.0 ${GUICE_SERVLET_NEW_VERSION}

# renovate: datasource=maven depName=guice lookupName=com.google.inject:guice
export GUICE_NEW_VERSION=6.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/inject/guice 6.0.0 ${GUICE_NEW_VERSION}

# renovate: datasource=maven depName=j2objc-annotations lookupName=com.google.j2objc:j2objc-annotations
export J2OBJC_ANNOTATIONS_NEW_VERSION=3.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/j2objc/j2objc-annotations 3.0.0 ${J2OBJC_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=google-oauth-client lookupName=com.google.oauth-client:google-oauth-client
export GOOGLE_OAUTH_CLIENT_NEW_VERSION=1.36.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/oauth-client/google-oauth-client 1.36.0 ${GOOGLE_OAUTH_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=protobuf-java-util lookupName=com.google.protobuf:protobuf-java-util
export PROTOBUF_JAVA_UTIL_NEW_VERSION=3.25.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/protobuf/protobuf-java-util 3.25.3 ${PROTOBUF_JAVA_UTIL_NEW_VERSION}

# renovate: datasource=maven depName=protobuf-java lookupName=com.google.protobuf:protobuf-java
export PROTOBUF_JAVA_NEW_VERSION=3.25.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/google/protobuf/protobuf-java 3.25.5 ${PROTOBUF_JAVA_NEW_VERSION}

# renovate: datasource=maven depName=h2 lookupName=com.h2database:h2
export H2_NEW_VERSION=2.3.232
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/h2database/h2 2.3.232 ${H2_NEW_VERSION}

# renovate: datasource=maven depName=json-schema-validator lookupName=com.networknt:json-schema-validator
export JSON_SCHEMA_VALIDATOR_NEW_VERSION=1.0.77
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/networknt/json-schema-validator 1.0.77 ${JSON_SCHEMA_VALIDATOR_NEW_VERSION}

# renovate: datasource=maven depName=scanner lookupName=com.neuvector:scanner
export SCANNER_NEW_VERSION=1.10
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/neuvector/scanner 1.10 ${SCANNER_NEW_VERSION}

# renovate: datasource=maven depName=compress-lzf lookupName=com.ning:compress-lzf
export COMPRESS_LZF_NEW_VERSION=1.1.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/ning/compress-lzf 1.1.2 ${COMPRESS_LZF_NEW_VERSION}

# renovate: datasource=maven depName=metrics-guice lookupName=com.palominolabs.metrics:metrics-guice
export METRICS_GUICE_NEW_VERSION=3.2.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/palominolabs/metrics/metrics-guice 3.2.2 ${METRICS_GUICE_NEW_VERSION}

# renovate: datasource=maven depName=profiler lookupName=com.papertrail:profiler
export PROFILER_NEW_VERSION=1.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/papertrail/profiler 1.0.2 ${PROFILER_NEW_VERSION}

# renovate: datasource=maven depName=com.sonatype.clm.dto.model lookupName=com.sonatype.clm:com.sonatype.clm.dto.model
export COM_SONATYPE_CLM_DTO_MODEL_NEW_VERSION=1.58.21-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/clm/com.sonatype.clm.dto.model 1.58.21-01 ${COM_SONATYPE_CLM_DTO_MODEL_NEW_VERSION}

# renovate: datasource=maven depName=insight-rm-common lookupName=com.sonatype.insight.brain:insight-rm-common
export INSIGHT_RM_COMMON_NEW_VERSION=1.170.0-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/brain/insight-rm-common 1.170.0-01 ${INSIGHT_RM_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=insight-scanner-core lookupName=com.sonatype.insight.scan:insight-scanner-core
export INSIGHT_SCANNER_CORE_NEW_VERSION=2.36.66-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/scan/insight-scanner-core 2.36.66-01 ${INSIGHT_SCANNER_CORE_NEW_VERSION}

# renovate: datasource=maven depName=insight-scanner-hashing-asm71 lookupName=com.sonatype.insight.scan:insight-scanner-hashing-asm71
export INSIGHT_SCANNER_HASHING_ASM71_NEW_VERSION=1.20.0-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/scan/insight-scanner-hashing-asm71 1.20.0-01 ${INSIGHT_SCANNER_HASHING_ASM71_NEW_VERSION}

# renovate: datasource=maven depName=insight-scanner-manifest-model lookupName=com.sonatype.insight.scan:insight-scanner-manifest-model
export INSIGHT_SCANNER_MANIFEST_MODEL_NEW_VERSION=2.36.66-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/scan/insight-scanner-manifest-model 2.36.66-01 ${INSIGHT_SCANNER_MANIFEST_MODEL_NEW_VERSION}

# renovate: datasource=maven depName=insight-scanner-model-io lookupName=com.sonatype.insight.scan:insight-scanner-model-io
export INSIGHT_SCANNER_MODEL_IO_NEW_VERSION=2.36.66-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/scan/insight-scanner-model-io 2.36.66-01 ${INSIGHT_SCANNER_MODEL_IO_NEW_VERSION}

# renovate: datasource=maven depName=insight-scanner-model lookupName=com.sonatype.insight.scan:insight-scanner-model
export INSIGHT_SCANNER_MODEL_NEW_VERSION=2.36.66-01
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/insight/scan/insight-scanner-model 2.36.66-01 ${INSIGHT_SCANNER_MODEL_NEW_VERSION}

# renovate: datasource=maven depName=license-bundle lookupName=com.sonatype.licensing:license-bundle
export LICENSE_BUNDLE_NEW_VERSION=1.6.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/licensing/license-bundle 1.6.0 ${LICENSE_BUNDLE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-licensing-extension lookupName=com.sonatype.nexus:nexus-licensing-extension
export NEXUS_LICENSING_EXTENSION_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/nexus-licensing-extension 3.76.0-03 ${NEXUS_LICENSING_EXTENSION_NEW_VERSION}

# renovate: datasource=maven depName=nexus-pro-edition lookupName=com.sonatype.nexus:nexus-pro-edition
export NEXUS_PRO_EDITION_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/nexus-pro-edition 3.76.0-03 ${NEXUS_PRO_EDITION_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ahc-plugin lookupName=com.sonatype.nexus.plugins:nexus-ahc-plugin
export NEXUS_AHC_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-ahc-plugin 3.76.0-03 ${NEXUS_AHC_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-analytics-plugin lookupName=com.sonatype.nexus.plugins:nexus-analytics-plugin
export NEXUS_ANALYTICS_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-analytics-plugin 3.76.0-03 ${NEXUS_ANALYTICS_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-api-extension-plugin lookupName=com.sonatype.nexus.plugins:nexus-api-extension-plugin
export NEXUS_API_EXTENSION_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-api-extension-plugin 3.76.0-03 ${NEXUS_API_EXTENSION_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-azure-cloud lookupName=com.sonatype.nexus.plugins:nexus-blobstore-azure-cloud
export NEXUS_BLOBSTORE_AZURE_CLOUD_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-blobstore-azure-cloud 3.76.0-03 ${NEXUS_BLOBSTORE_AZURE_CLOUD_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-database-sync lookupName=com.sonatype.nexus.plugins:nexus-blobstore-database-sync
export NEXUS_BLOBSTORE_DATABASE_SYNC_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-blobstore-database-sync 3.76.0-03 ${NEXUS_BLOBSTORE_DATABASE_SYNC_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-google-cloud lookupName=com.sonatype.nexus.plugins:nexus-blobstore-google-cloud
export NEXUS_BLOBSTORE_GOOGLE_CLOUD_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-blobstore-google-cloud 3.76.0-03 ${NEXUS_BLOBSTORE_GOOGLE_CLOUD_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-group lookupName=com.sonatype.nexus.plugins:nexus-blobstore-group
export NEXUS_BLOBSTORE_GROUP_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-blobstore-group 3.76.0-03 ${NEXUS_BLOBSTORE_GROUP_NEW_VERSION}

# renovate: datasource=maven depName=nexus-cleanup-pro-plugin lookupName=com.sonatype.nexus.plugins:nexus-cleanup-pro-plugin
export NEXUS_CLEANUP_PRO_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-cleanup-pro-plugin 3.76.0-03 ${NEXUS_CLEANUP_PRO_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-clm-oss-plugin lookupName=com.sonatype.nexus.plugins:nexus-clm-oss-plugin
export NEXUS_CLM_OSS_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-clm-oss-plugin 3.76.0-03 ${NEXUS_CLM_OSS_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-clm-plugin lookupName=com.sonatype.nexus.plugins:nexus-clm-plugin
export NEXUS_CLM_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-clm-plugin 3.76.0-03 ${NEXUS_CLM_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-common-pro-plugin lookupName=com.sonatype.nexus.plugins:nexus-common-pro-plugin
export NEXUS_COMMON_PRO_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-common-pro-plugin 3.76.0-03 ${NEXUS_COMMON_PRO_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-crowd-plugin lookupName=com.sonatype.nexus.plugins:nexus-crowd-plugin
export NEXUS_CROWD_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-crowd-plugin 3.76.0-03 ${NEXUS_CROWD_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-datastore-clustering lookupName=com.sonatype.nexus.plugins:nexus-datastore-clustering
export NEXUS_DATASTORE_CLUSTERING_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-datastore-clustering 3.76.0-03 ${NEXUS_DATASTORE_CLUSTERING_NEW_VERSION}

# renovate: datasource=maven depName=nexus-export-import-plugin lookupName=com.sonatype.nexus.plugins:nexus-export-import-plugin
export NEXUS_EXPORT_IMPORT_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-export-import-plugin 3.76.0-03 ${NEXUS_EXPORT_IMPORT_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-firewall-common lookupName=com.sonatype.nexus.plugins:nexus-firewall-common
export NEXUS_FIREWALL_COMMON_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-firewall-common 3.76.0-03 ${NEXUS_FIREWALL_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=nexus-group-deploy lookupName=com.sonatype.nexus.plugins:nexus-group-deploy
export NEXUS_GROUP_DEPLOY_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-group-deploy 3.76.0-03 ${NEXUS_GROUP_DEPLOY_NEW_VERSION}

# renovate: datasource=maven depName=nexus-healthcheck-base lookupName=com.sonatype.nexus.plugins:nexus-healthcheck-base
export NEXUS_HEALTHCHECK_BASE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-healthcheck-base 3.76.0-03 ${NEXUS_HEALTHCHECK_BASE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ldap-plugin lookupName=com.sonatype.nexus.plugins:nexus-ldap-plugin
export NEXUS_LDAP_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-ldap-plugin 3.76.0-03 ${NEXUS_LDAP_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-licensing-plugin lookupName=com.sonatype.nexus.plugins:nexus-licensing-plugin
export NEXUS_LICENSING_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-licensing-plugin 3.76.0-03 ${NEXUS_LICENSING_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-malicious-risk-plugin lookupName=com.sonatype.nexus.plugins:nexus-malicious-risk-plugin
export NEXUS_MALICIOUS_RISK_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-malicious-risk-plugin 3.76.0-03 ${NEXUS_MALICIOUS_RISK_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-migration-plugin lookupName=com.sonatype.nexus.plugins:nexus-migration-plugin
export NEXUS_MIGRATION_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-migration-plugin 3.76.0-03 ${NEXUS_MIGRATION_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ossindex-plugin lookupName=com.sonatype.nexus.plugins:nexus-ossindex-plugin
export NEXUS_OSSINDEX_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-ossindex-plugin 3.76.0-03 ${NEXUS_OSSINDEX_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-outreach-plugin lookupName=com.sonatype.nexus.plugins:nexus-outreach-plugin
export NEXUS_OUTREACH_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-outreach-plugin 3.76.0-03 ${NEXUS_OUTREACH_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-pro-datastore-plugin lookupName=com.sonatype.nexus.plugins:nexus-pro-datastore-plugin
export NEXUS_PRO_DATASTORE_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-pro-datastore-plugin 3.76.0-03 ${NEXUS_PRO_DATASTORE_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-pro-system-checks-plugin lookupName=com.sonatype.nexus.plugins:nexus-pro-system-checks-plugin
export NEXUS_PRO_SYSTEM_CHECKS_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-pro-system-checks-plugin 3.76.0-03 ${NEXUS_PRO_SYSTEM_CHECKS_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-proui-plugin lookupName=com.sonatype.nexus.plugins:nexus-proui-plugin
export NEXUS_PROUI_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-proui-plugin 3.76.0-03 ${NEXUS_PROUI_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-proximanova-plugin lookupName=com.sonatype.nexus.plugins:nexus-proximanova-plugin
export NEXUS_PROXIMANOVA_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-proximanova-plugin 3.76.0-03 ${NEXUS_PROXIMANOVA_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-replication-plugin lookupName=com.sonatype.nexus.plugins:nexus-replication-plugin
export NEXUS_REPLICATION_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-replication-plugin 3.76.0-03 ${NEXUS_REPLICATION_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-cargo lookupName=com.sonatype.nexus.plugins:nexus-repository-cargo
export NEXUS_REPOSITORY_CARGO_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-cargo 3.76.0-03 ${NEXUS_REPOSITORY_CARGO_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-cocoapods lookupName=com.sonatype.nexus.plugins:nexus-repository-cocoapods
export NEXUS_REPOSITORY_COCOAPODS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-cocoapods 3.76.0-03 ${NEXUS_REPOSITORY_COCOAPODS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-composer lookupName=com.sonatype.nexus.plugins:nexus-repository-composer
export NEXUS_REPOSITORY_COMPOSER_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-composer 3.76.0-03 ${NEXUS_REPOSITORY_COMPOSER_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-conan lookupName=com.sonatype.nexus.plugins:nexus-repository-conan
export NEXUS_REPOSITORY_CONAN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-conan 3.76.0-03 ${NEXUS_REPOSITORY_CONAN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-conda lookupName=com.sonatype.nexus.plugins:nexus-repository-conda
export NEXUS_REPOSITORY_CONDA_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-conda 3.76.0-03 ${NEXUS_REPOSITORY_CONDA_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-docker lookupName=com.sonatype.nexus.plugins:nexus-repository-docker
export NEXUS_REPOSITORY_DOCKER_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-docker 3.76.0-03 ${NEXUS_REPOSITORY_DOCKER_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-gitlfs lookupName=com.sonatype.nexus.plugins:nexus-repository-gitlfs
export NEXUS_REPOSITORY_GITLFS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-gitlfs 3.76.0-03 ${NEXUS_REPOSITORY_GITLFS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-golang lookupName=com.sonatype.nexus.plugins:nexus-repository-golang
export NEXUS_REPOSITORY_GOLANG_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-golang 3.76.0-03 ${NEXUS_REPOSITORY_GOLANG_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-helm lookupName=com.sonatype.nexus.plugins:nexus-repository-helm
export NEXUS_REPOSITORY_HELM_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-helm 3.76.0-03 ${NEXUS_REPOSITORY_HELM_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-huggingface lookupName=com.sonatype.nexus.plugins:nexus-repository-huggingface
export NEXUS_REPOSITORY_HUGGINGFACE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-huggingface 3.76.0-03 ${NEXUS_REPOSITORY_HUGGINGFACE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-move-plugin lookupName=com.sonatype.nexus.plugins:nexus-repository-move-plugin
export NEXUS_REPOSITORY_MOVE_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-move-plugin 3.76.0-03 ${NEXUS_REPOSITORY_MOVE_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-npm lookupName=com.sonatype.nexus.plugins:nexus-repository-npm
export NEXUS_REPOSITORY_NPM_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-npm 3.76.0-03 ${NEXUS_REPOSITORY_NPM_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-nuget lookupName=com.sonatype.nexus.plugins:nexus-repository-nuget
export NEXUS_REPOSITORY_NUGET_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-nuget 3.76.0-03 ${NEXUS_REPOSITORY_NUGET_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-p2 lookupName=com.sonatype.nexus.plugins:nexus-repository-p2
export NEXUS_REPOSITORY_P2_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-p2 3.76.0-03 ${NEXUS_REPOSITORY_P2_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-pypi lookupName=com.sonatype.nexus.plugins:nexus-repository-pypi
export NEXUS_REPOSITORY_PYPI_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-pypi 3.76.0-03 ${NEXUS_REPOSITORY_PYPI_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-r lookupName=com.sonatype.nexus.plugins:nexus-repository-r
export NEXUS_REPOSITORY_R_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-r 3.76.0-03 ${NEXUS_REPOSITORY_R_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-rubygems lookupName=com.sonatype.nexus.plugins:nexus-repository-rubygems
export NEXUS_REPOSITORY_RUBYGEMS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-rubygems 3.76.0-03 ${NEXUS_REPOSITORY_RUBYGEMS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-yum lookupName=com.sonatype.nexus.plugins:nexus-repository-yum
export NEXUS_REPOSITORY_YUM_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-repository-yum 3.76.0-03 ${NEXUS_REPOSITORY_YUM_NEW_VERSION}

# renovate: datasource=maven depName=nexus-rutauth-plugin lookupName=com.sonatype.nexus.plugins:nexus-rutauth-plugin
export NEXUS_RUTAUTH_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-rutauth-plugin 3.76.0-03 ${NEXUS_RUTAUTH_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-saml-plugin lookupName=com.sonatype.nexus.plugins:nexus-saml-plugin
export NEXUS_SAML_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-saml-plugin 3.76.0-03 ${NEXUS_SAML_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-staging-plugin lookupName=com.sonatype.nexus.plugins:nexus-staging-plugin
export NEXUS_STAGING_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-staging-plugin 3.76.0-03 ${NEXUS_STAGING_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-tags-plugin lookupName=com.sonatype.nexus.plugins:nexus-tags-plugin
export NEXUS_TAGS_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-tags-plugin 3.76.0-03 ${NEXUS_TAGS_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-usertoken-plugin lookupName=com.sonatype.nexus.plugins:nexus-usertoken-plugin
export NEXUS_USERTOKEN_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-usertoken-plugin 3.76.0-03 ${NEXUS_USERTOKEN_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-vulnerability-plugin lookupName=com.sonatype.nexus.plugins:nexus-vulnerability-plugin
export NEXUS_VULNERABILITY_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sonatype/nexus/plugins/nexus-vulnerability-plugin 3.76.0-03 ${NEXUS_VULNERABILITY_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=tape lookupName=com.squareup:tape
export TAPE_NEW_VERSION=1.2.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/squareup/tape 1.2.3 ${TAPE_NEW_VERSION}

# renovate: datasource=maven depName=jakarta.mail lookupName=com.sun.mail:jakarta.mail
export JAKARTA_MAIL_NEW_VERSION=1.6.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sun/mail/jakarta.mail 1.6.5 ${JAKARTA_MAIL_NEW_VERSION}

# renovate: datasource=maven depName=javax.mail lookupName=com.sun.mail:javax.mail
export JAVAX_MAIL_NEW_VERSION=1.6.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/sun/mail/javax.mail 1.6.2 ${JAVAX_MAIL_NEW_VERSION}

# renovate: datasource=maven depName=paranamer lookupName=com.thoughtworks.paranamer:paranamer
export PARANAMER_NEW_VERSION=2.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/thoughtworks/paranamer/paranamer 2.8 ${PARANAMER_NEW_VERSION}

# renovate: datasource=maven depName=xstream lookupName=com.thoughtworks.xstream:xstream
export XSTREAM_NEW_VERSION=1.4.21
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/thoughtworks/xstream/xstream 1.4.21 ${XSTREAM_NEW_VERSION}

# renovate: datasource=maven depName=jts lookupName=com.vividsolutions:jts
export JTS_NEW_VERSION=1.13
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/vividsolutions/jts 1.13 ${JTS_NEW_VERSION}

# renovate: datasource=maven depName=HikariCP-java7 lookupName=com.zaxxer:HikariCP-java7
export HIKARICP_JAVA7_NEW_VERSION=2.4.13
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/zaxxer/HikariCP-java7 2.4.13 ${HIKARICP_JAVA7_NEW_VERSION}

# renovate: datasource=maven depName=HikariCP lookupName=com.zaxxer:HikariCP
export HIKARICP_NEW_VERSION=4.0.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME com/zaxxer/HikariCP 4.0.3 ${HIKARICP_NEW_VERSION}

# renovate: datasource=maven depName=commons-beanutils lookupName=commons-beanutils:commons-beanutils
export COMMONS_BEANUTILS_NEW_VERSION=1.9.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-beanutils/commons-beanutils 1.9.4 ${COMMONS_BEANUTILS_NEW_VERSION}

# renovate: datasource=maven depName=commons-cli lookupName=commons-cli:commons-cli
export COMMONS_CLI_NEW_VERSION=1.7.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-cli/commons-cli 1.7.0 ${COMMONS_CLI_NEW_VERSION}

# renovate: datasource=maven depName=commons-codec lookupName=commons-codec:commons-codec
export COMMONS_CODEC_NEW_VERSION=1.16.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-codec/commons-codec 1.16.0 ${COMMONS_CODEC_NEW_VERSION}

# renovate: datasource=maven depName=commons-collections lookupName=commons-collections:commons-collections
export COMMONS_COLLECTIONS_NEW_VERSION=3.2.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-collections/commons-collections 3.2.2 ${COMMONS_COLLECTIONS_NEW_VERSION}

# renovate: datasource=maven depName=commons-fileupload lookupName=commons-fileupload:commons-fileupload
export COMMONS_FILEUPLOAD_NEW_VERSION=1.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-fileupload/commons-fileupload 1.5 ${COMMONS_FILEUPLOAD_NEW_VERSION}

# renovate: datasource=maven depName=commons-io lookupName=commons-io:commons-io
export COMMONS_IO_NEW_VERSION=2.15.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-io/commons-io 2.15.1 ${COMMONS_IO_NEW_VERSION}

# renovate: datasource=maven depName=commons-lang lookupName=commons-lang:commons-lang
export COMMONS_LANG_NEW_VERSION=2.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME commons-lang/commons-lang 2.6 ${COMMONS_LANG_NEW_VERSION}

# renovate: datasource=maven depName=UserAgentUtils lookupName=eu.bitwalker:UserAgentUtils
export USERAGENTUTILS_NEW_VERSION=1.21
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME eu/bitwalker/UserAgentUtils 1.21 ${USERAGENTUTILS_NEW_VERSION}

# renovate: datasource=maven depName=metrics-annotation lookupName=io.dropwizard.metrics:metrics-annotation
export METRICS_ANNOTATION_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-annotation 4.1.0 ${METRICS_ANNOTATION_NEW_VERSION}

# renovate: datasource=maven depName=metrics-core lookupName=io.dropwizard.metrics:metrics-core
export METRICS_CORE_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-core 4.1.0 ${METRICS_CORE_NEW_VERSION}

# renovate: datasource=maven depName=metrics-healthchecks lookupName=io.dropwizard.metrics:metrics-healthchecks
export METRICS_HEALTHCHECKS_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-healthchecks 4.1.0 ${METRICS_HEALTHCHECKS_NEW_VERSION}

# renovate: datasource=maven depName=metrics-httpclient lookupName=io.dropwizard.metrics:metrics-httpclient
export METRICS_HTTPCLIENT_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-httpclient 4.1.0 ${METRICS_HTTPCLIENT_NEW_VERSION}

# renovate: datasource=maven depName=metrics-jetty9 lookupName=io.dropwizard.metrics:metrics-jetty9
export METRICS_JETTY9_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-jetty9 4.1.0 ${METRICS_JETTY9_NEW_VERSION}

# renovate: datasource=maven depName=metrics-json lookupName=io.dropwizard.metrics:metrics-json
export METRICS_JSON_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-json 4.1.0 ${METRICS_JSON_NEW_VERSION}

# renovate: datasource=maven depName=metrics-jvm lookupName=io.dropwizard.metrics:metrics-jvm
export METRICS_JVM_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-jvm 4.1.0 ${METRICS_JVM_NEW_VERSION}

# renovate: datasource=maven depName=metrics-logback lookupName=io.dropwizard.metrics:metrics-logback
export METRICS_LOGBACK_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-logback 4.1.0 ${METRICS_LOGBACK_NEW_VERSION}

# renovate: datasource=maven depName=metrics-servlet lookupName=io.dropwizard.metrics:metrics-servlet
export METRICS_SERVLET_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-servlet 4.1.0 ${METRICS_SERVLET_NEW_VERSION}

# renovate: datasource=maven depName=metrics-servlets lookupName=io.dropwizard.metrics:metrics-servlets
export METRICS_SERVLETS_NEW_VERSION=4.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/dropwizard/metrics/metrics-servlets 4.1.0 ${METRICS_SERVLETS_NEW_VERSION}

# renovate: datasource=maven depName=grpc-alts lookupName=io.grpc:grpc-alts
export GRPC_ALTS_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-alts 1.62.2 ${GRPC_ALTS_NEW_VERSION}

# renovate: datasource=maven depName=grpc-api lookupName=io.grpc:grpc-api
export GRPC_API_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-api 1.62.2 ${GRPC_API_NEW_VERSION}

# renovate: datasource=maven depName=grpc-auth lookupName=io.grpc:grpc-auth
export GRPC_AUTH_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-auth 1.62.2 ${GRPC_AUTH_NEW_VERSION}

# renovate: datasource=maven depName=grpc-context lookupName=io.grpc:grpc-context
export GRPC_CONTEXT_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-context 1.62.2 ${GRPC_CONTEXT_NEW_VERSION}

# renovate: datasource=maven depName=grpc-core lookupName=io.grpc:grpc-core
export GRPC_CORE_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-core 1.62.2 ${GRPC_CORE_NEW_VERSION}

# renovate: datasource=maven depName=grpc-grpclb lookupName=io.grpc:grpc-grpclb
export GRPC_GRPCLB_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-grpclb 1.62.2 ${GRPC_GRPCLB_NEW_VERSION}

# renovate: datasource=maven depName=grpc-inprocess lookupName=io.grpc:grpc-inprocess
export GRPC_INPROCESS_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-inprocess 1.62.2 ${GRPC_INPROCESS_NEW_VERSION}

# renovate: datasource=maven depName=grpc-netty-shaded lookupName=io.grpc:grpc-netty-shaded
export GRPC_NETTY_SHADED_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-netty-shaded 1.62.2 ${GRPC_NETTY_SHADED_NEW_VERSION}

# renovate: datasource=maven depName=grpc-protobuf lookupName=io.grpc:grpc-protobuf
export GRPC_PROTOBUF_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-protobuf 1.62.2 ${GRPC_PROTOBUF_NEW_VERSION}

# renovate: datasource=maven depName=grpc-stub lookupName=io.grpc:grpc-stub
export GRPC_STUB_NEW_VERSION=1.62.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/grpc/grpc-stub 1.62.2 ${GRPC_STUB_NEW_VERSION}

# renovate: datasource=maven depName=opencensus-api lookupName=io.opencensus:opencensus-api
export OPENCENSUS_API_NEW_VERSION=0.31.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/opencensus/opencensus-api 0.31.1 ${OPENCENSUS_API_NEW_VERSION}

# renovate: datasource=maven depName=opencensus-contrib-http-util lookupName=io.opencensus:opencensus-contrib-http-util
export OPENCENSUS_CONTRIB_HTTP_UTIL_NEW_VERSION=0.31.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/opencensus/opencensus-contrib-http-util 0.31.1 ${OPENCENSUS_CONTRIB_HTTP_UTIL_NEW_VERSION}

# renovate: datasource=maven depName=simpleclient lookupName=io.prometheus:simpleclient
export SIMPLECLIENT_NEW_VERSION=0.6.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/prometheus/simpleclient 0.6.0 ${SIMPLECLIENT_NEW_VERSION}

# renovate: datasource=maven depName=simpleclient_common lookupName=io.prometheus:simpleclient_common
export SIMPLECLIENT_COMMON_NEW_VERSION=0.6.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/prometheus/simpleclient_common 0.6.0 ${SIMPLECLIENT_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=simpleclient_dropwizard lookupName=io.prometheus:simpleclient_dropwizard
export SIMPLECLIENT_DROPWIZARD_NEW_VERSION=0.6.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/prometheus/simpleclient_dropwizard 0.6.0 ${SIMPLECLIENT_DROPWIZARD_NEW_VERSION}

# renovate: datasource=maven depName=simpleclient_servlet lookupName=io.prometheus:simpleclient_servlet
export SIMPLECLIENT_SERVLET_NEW_VERSION=0.6.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/prometheus/simpleclient_servlet 0.6.0 ${SIMPLECLIENT_SERVLET_NEW_VERSION}

# renovate: datasource=maven depName=swagger-annotations lookupName=io.swagger:swagger-annotations
export SWAGGER_ANNOTATIONS_NEW_VERSION=1.6.11
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/swagger/swagger-annotations 1.6.11 ${SWAGGER_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=swagger-core lookupName=io.swagger:swagger-core
export SWAGGER_CORE_NEW_VERSION=1.6.11
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/swagger/swagger-core 1.6.11 ${SWAGGER_CORE_NEW_VERSION}

# renovate: datasource=maven depName=swagger-jaxrs lookupName=io.swagger:swagger-jaxrs
export SWAGGER_JAXRS_NEW_VERSION=1.6.11
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/swagger/swagger-jaxrs 1.6.11 ${SWAGGER_JAXRS_NEW_VERSION}

# renovate: datasource=maven depName=swagger-models lookupName=io.swagger:swagger-models
export SWAGGER_MODELS_NEW_VERSION=1.6.11
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME io/swagger/swagger-models 1.6.11 ${SWAGGER_MODELS_NEW_VERSION}

# renovate: datasource=maven depName=jakarta.activation-api lookupName=jakarta.activation:jakarta.activation-api
export JAKARTA_ACTIVATION_API_NEW_VERSION=1.2.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME jakarta/activation/jakarta.activation-api 1.2.2 ${JAKARTA_ACTIVATION_API_NEW_VERSION}

# renovate: datasource=maven depName=jakarta.inject-api lookupName=jakarta.inject:jakarta.inject-api
export JAKARTA_INJECT_API_NEW_VERSION=2.0.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME jakarta/inject/jakarta.inject-api 2.0.1 ${JAKARTA_INJECT_API_NEW_VERSION}

# renovate: datasource=maven depName=jakarta.validation-api lookupName=jakarta.validation:jakarta.validation-api
export JAKARTA_VALIDATION_API_NEW_VERSION=2.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME jakarta/validation/jakarta.validation-api 2.0.2 ${JAKARTA_VALIDATION_API_NEW_VERSION}

# renovate: datasource=maven depName=cache-api lookupName=javax.cache:cache-api
export CACHE_API_NEW_VERSION=1.1.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/cache/cache-api 1.1.1 ${CACHE_API_NEW_VERSION}

# renovate: datasource=maven depName=javax.el-api lookupName=javax.el:javax.el-api
export JAVAX_EL_API_NEW_VERSION=3.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/el/javax.el-api 3.0.0 ${JAVAX_EL_API_NEW_VERSION}

# renovate: datasource=maven depName=cdi-api lookupName=javax.enterprise:cdi-api
export CDI_API_NEW_VERSION=1.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/enterprise/cdi-api 1.2 ${CDI_API_NEW_VERSION}

# renovate: datasource=maven depName=javax.interceptor-api lookupName=javax.interceptor:javax.interceptor-api
export JAVAX_INTERCEPTOR_API_NEW_VERSION=1.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/interceptor/javax.interceptor-api 1.2 ${JAVAX_INTERCEPTOR_API_NEW_VERSION}

# renovate: datasource=maven depName=javax.servlet-api lookupName=javax.servlet:javax.servlet-api
export JAVAX_SERVLET_API_NEW_VERSION=3.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/servlet/javax.servlet-api 3.1.0 ${JAVAX_SERVLET_API_NEW_VERSION}

# renovate: datasource=maven depName=jsr311-api lookupName=javax.ws.rs:jsr311-api
export JSR311_API_NEW_VERSION=1.1.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME javax/ws/rs/jsr311-api 1.1.1 ${JSR311_API_NEW_VERSION}

# renovate: datasource=maven depName=joda-time lookupName=joda-time:joda-time
export JODA_TIME_NEW_VERSION=2.10.14
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME joda-time/joda-time 2.10.14 ${JODA_TIME_NEW_VERSION}

# renovate: datasource=maven depName=byte-buddy lookupName=net.bytebuddy:byte-buddy
export BYTE_BUDDY_NEW_VERSION=1.14.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME net/bytebuddy/byte-buddy 1.14.9 ${BYTE_BUDDY_NEW_VERSION}

# renovate: datasource=maven depName=jna lookupName=net.java.dev.jna:jna
export JNA_NEW_VERSION=5.13.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME net/java/dev/jna/jna 5.13.0 ${JNA_NEW_VERSION}

# renovate: datasource=maven depName=antlr4-runtime lookupName=org.antlr:antlr4-runtime
export ANTLR4_RUNTIME_NEW_VERSION=4.7.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/antlr/antlr4-runtime 4.7.2 ${ANTLR4_RUNTIME_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.jmx.api lookupName=org.apache.aries.jmx:org.apache.aries.jmx.api
export ORG_APACHE_ARIES_JMX_API_NEW_VERSION=1.1.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/jmx/org.apache.aries.jmx.api 1.1.5 ${ORG_APACHE_ARIES_JMX_API_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.jmx.blueprint.api lookupName=org.apache.aries.jmx:org.apache.aries.jmx.blueprint.api
export ORG_APACHE_ARIES_JMX_BLUEPRINT_API_NEW_VERSION=1.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/jmx/org.apache.aries.jmx.blueprint.api 1.2.0 ${ORG_APACHE_ARIES_JMX_BLUEPRINT_API_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.jmx.blueprint.core lookupName=org.apache.aries.jmx:org.apache.aries.jmx.blueprint.core
export ORG_APACHE_ARIES_JMX_BLUEPRINT_CORE_NEW_VERSION=1.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/jmx/org.apache.aries.jmx.blueprint.core 1.2.0 ${ORG_APACHE_ARIES_JMX_BLUEPRINT_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.jmx.core lookupName=org.apache.aries.jmx:org.apache.aries.jmx.core
export ORG_APACHE_ARIES_JMX_CORE_NEW_VERSION=1.1.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/jmx/org.apache.aries.jmx.core 1.1.8 ${ORG_APACHE_ARIES_JMX_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.jmx.whiteboard lookupName=org.apache.aries.jmx:org.apache.aries.jmx.whiteboard
export ORG_APACHE_ARIES_JMX_WHITEBOARD_NEW_VERSION=1.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/jmx/org.apache.aries.jmx.whiteboard 1.2.0 ${ORG_APACHE_ARIES_JMX_WHITEBOARD_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.util lookupName=org.apache.aries:org.apache.aries.util
export ORG_APACHE_ARIES_UTIL_NEW_VERSION=1.1.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/org.apache.aries.util 1.1.3 ${ORG_APACHE_ARIES_UTIL_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.aries.spifly.dynamic.framework.extension lookupName=org.apache.aries.spifly:org.apache.aries.spifly.dynamic.framework.extension
export ORG_APACHE_ARIES_SPIFLY_DYNAMIC_FRAMEWORK_EXTENSION_NEW_VERSION=1.3.7
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/aries/spifly/org.apache.aries.spifly.dynamic.framework.extension 1.3.7 ${ORG_APACHE_ARIES_SPIFLY_DYNAMIC_FRAMEWORK_EXTENSION_NEW_VERSION}

# renovate: datasource=maven depName=commons-collections4 lookupName=org.apache.commons:commons-collections4
export COMMONS_COLLECTIONS4_NEW_VERSION=4.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-collections4 4.4 ${COMMONS_COLLECTIONS4_NEW_VERSION}

# renovate: datasource=maven depName=commons-compress lookupName=org.apache.commons:commons-compress
export COMMONS_COMPRESS_NEW_VERSION=1.26.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-compress 1.26.1 ${COMMONS_COMPRESS_NEW_VERSION}

# renovate: datasource=maven depName=commons-csv lookupName=org.apache.commons:commons-csv
export COMMONS_CSV_NEW_VERSION=1.10.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-csv 1.10.0 ${COMMONS_CSV_NEW_VERSION}

# renovate: datasource=maven depName=commons-email lookupName=org.apache.commons:commons-email
export COMMONS_EMAIL_NEW_VERSION=1.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-email 1.5 ${COMMONS_EMAIL_NEW_VERSION}

# renovate: datasource=maven depName=commons-jexl3 lookupName=org.apache.commons:commons-jexl3
export COMMONS_JEXL3_NEW_VERSION=3.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-jexl3 3.1 ${COMMONS_JEXL3_NEW_VERSION}

# renovate: datasource=maven depName=commons-lang3 lookupName=org.apache.commons:commons-lang3
export COMMONS_LANG3_NEW_VERSION=3.13.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-lang3 3.13.0 ${COMMONS_LANG3_NEW_VERSION}

# renovate: datasource=maven depName=commons-text lookupName=org.apache.commons:commons-text
export COMMONS_TEXT_NEW_VERSION=1.12.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/commons/commons-text 1.12.0 ${COMMONS_TEXT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.cm.json lookupName=org.apache.felix:org.apache.felix.cm.json
export ORG_APACHE_FELIX_CM_JSON_NEW_VERSION=1.0.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.cm.json 1.0.6 ${ORG_APACHE_FELIX_CM_JSON_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.configadmin.plugin.interpolation lookupName=org.apache.felix:org.apache.felix.configadmin.plugin.interpolation
export ORG_APACHE_FELIX_CONFIGADMIN_PLUGIN_INTERPOLATION_NEW_VERSION=1.2.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.configadmin.plugin.interpolation 1.2.6 ${ORG_APACHE_FELIX_CONFIGADMIN_PLUGIN_INTERPOLATION_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.configadmin lookupName=org.apache.felix:org.apache.felix.configadmin
export ORG_APACHE_FELIX_CONFIGADMIN_NEW_VERSION=1.9.26
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.configadmin 1.9.26 ${ORG_APACHE_FELIX_CONFIGADMIN_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.configurator lookupName=org.apache.felix:org.apache.felix.configurator
export ORG_APACHE_FELIX_CONFIGURATOR_NEW_VERSION=1.0.16
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.configurator 1.0.16 ${ORG_APACHE_FELIX_CONFIGURATOR_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.converter lookupName=org.apache.felix:org.apache.felix.converter
export ORG_APACHE_FELIX_CONVERTER_NEW_VERSION=1.0.14
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.converter 1.0.14 ${ORG_APACHE_FELIX_CONVERTER_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.coordinator lookupName=org.apache.felix:org.apache.felix.coordinator
export ORG_APACHE_FELIX_COORDINATOR_NEW_VERSION=1.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.coordinator 1.0.2 ${ORG_APACHE_FELIX_COORDINATOR_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.fileinstall lookupName=org.apache.felix:org.apache.felix.fileinstall
export ORG_APACHE_FELIX_FILEINSTALL_NEW_VERSION=3.7.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.fileinstall 3.7.4 ${ORG_APACHE_FELIX_FILEINSTALL_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.framework lookupName=org.apache.felix:org.apache.felix.framework
export ORG_APACHE_FELIX_FRAMEWORK_NEW_VERSION=6.0.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.framework 6.0.5 ${ORG_APACHE_FELIX_FRAMEWORK_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.framework lookupName=org.apache.felix:org.apache.felix.framework
export ORG_APACHE_FELIX_FRAMEWORK_NEW_VERSION=7.0.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.framework 7.0.5 ${ORG_APACHE_FELIX_FRAMEWORK_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.gogo.runtime lookupName=org.apache.felix:org.apache.felix.gogo.runtime
export ORG_APACHE_FELIX_GOGO_RUNTIME_NEW_VERSION=1.1.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.gogo.runtime 1.1.6 ${ORG_APACHE_FELIX_GOGO_RUNTIME_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.inventory lookupName=org.apache.felix:org.apache.felix.inventory
export ORG_APACHE_FELIX_INVENTORY_NEW_VERSION=1.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.inventory 1.1.0 ${ORG_APACHE_FELIX_INVENTORY_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.metatype lookupName=org.apache.felix:org.apache.felix.metatype
export ORG_APACHE_FELIX_METATYPE_NEW_VERSION=1.2.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.metatype 1.2.2 ${ORG_APACHE_FELIX_METATYPE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.metatype lookupName=org.apache.felix:org.apache.felix.metatype
export ORG_APACHE_FELIX_METATYPE_NEW_VERSION=1.2.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.metatype 1.2.4 ${ORG_APACHE_FELIX_METATYPE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.scr lookupName=org.apache.felix:org.apache.felix.scr
export ORG_APACHE_FELIX_SCR_NEW_VERSION=2.1.30
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.scr 2.1.30 ${ORG_APACHE_FELIX_SCR_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.felix.webconsole.plugins.ds lookupName=org.apache.felix:org.apache.felix.webconsole.plugins.ds
export ORG_APACHE_FELIX_WEBCONSOLE_PLUGINS_DS_NEW_VERSION=2.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/felix/org.apache.felix.webconsole.plugins.ds 2.2.0 ${ORG_APACHE_FELIX_WEBCONSOLE_PLUGINS_DS_NEW_VERSION}

# renovate: datasource=maven depName=httpclient lookupName=org.apache.httpcomponents:httpclient
export HTTPCLIENT_NEW_VERSION=4.5.14
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/httpcomponents/httpclient 4.5.14 ${HTTPCLIENT_NEW_VERSION}

# renovate: datasource=maven depName=httpcore lookupName=org.apache.httpcomponents:httpcore
export HTTPCORE_NEW_VERSION=4.4.15
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/httpcomponents/httpcore 4.4.15 ${HTTPCORE_NEW_VERSION}

# renovate: datasource=maven depName=apache-mime4j-core lookupName=org.apache.james:apache-mime4j-core
export APACHE_MIME4J_CORE_NEW_VERSION=0.8.10
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/james/apache-mime4j-core 0.8.10 ${APACHE_MIME4J_CORE_NEW_VERSION}

# renovate: datasource=maven depName=apache-mime4j-dom lookupName=org.apache.james:apache-mime4j-dom
export APACHE_MIME4J_DOM_NEW_VERSION=0.8.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/james/apache-mime4j-dom 0.8.9 ${APACHE_MIME4J_DOM_NEW_VERSION}

# renovate: datasource=maven depName=apache-mime4j-storage lookupName=org.apache.james:apache-mime4j-storage
export APACHE_MIME4J_STORAGE_NEW_VERSION=0.8.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/james/apache-mime4j-storage 0.8.9 ${APACHE_MIME4J_STORAGE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.bundle.core lookupName=org.apache.karaf.bundle:org.apache.karaf.bundle.core
export ORG_APACHE_KARAF_BUNDLE_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/bundle/org.apache.karaf.bundle.core 4.3.9 ${ORG_APACHE_KARAF_BUNDLE_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.config.core lookupName=org.apache.karaf.config:org.apache.karaf.config.core
export ORG_APACHE_KARAF_CONFIG_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/config/org.apache.karaf.config.core 4.3.9 ${ORG_APACHE_KARAF_CONFIG_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.deployer.blueprint lookupName=org.apache.karaf.deployer:org.apache.karaf.deployer.blueprint
export ORG_APACHE_KARAF_DEPLOYER_BLUEPRINT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/deployer/org.apache.karaf.deployer.blueprint 4.3.9 ${ORG_APACHE_KARAF_DEPLOYER_BLUEPRINT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.deployer.features lookupName=org.apache.karaf.deployer:org.apache.karaf.deployer.features
export ORG_APACHE_KARAF_DEPLOYER_FEATURES_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/deployer/org.apache.karaf.deployer.features 4.3.9 ${ORG_APACHE_KARAF_DEPLOYER_FEATURES_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.deployer.kar lookupName=org.apache.karaf.deployer:org.apache.karaf.deployer.kar
export ORG_APACHE_KARAF_DEPLOYER_KAR_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/deployer/org.apache.karaf.deployer.kar 4.3.9 ${ORG_APACHE_KARAF_DEPLOYER_KAR_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.deployer.wrap lookupName=org.apache.karaf.deployer:org.apache.karaf.deployer.wrap
export ORG_APACHE_KARAF_DEPLOYER_WRAP_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/deployer/org.apache.karaf.deployer.wrap 4.3.9 ${ORG_APACHE_KARAF_DEPLOYER_WRAP_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.diagnostic.boot lookupName=org.apache.karaf.diagnostic:org.apache.karaf.diagnostic.boot
export ORG_APACHE_KARAF_DIAGNOSTIC_BOOT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/diagnostic/org.apache.karaf.diagnostic.boot 4.3.9 ${ORG_APACHE_KARAF_DIAGNOSTIC_BOOT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.diagnostic.core lookupName=org.apache.karaf.diagnostic:org.apache.karaf.diagnostic.core
export ORG_APACHE_KARAF_DIAGNOSTIC_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/diagnostic/org.apache.karaf.diagnostic.core 4.3.9 ${ORG_APACHE_KARAF_DIAGNOSTIC_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.features.command lookupName=org.apache.karaf.features:org.apache.karaf.features.command
export ORG_APACHE_KARAF_FEATURES_COMMAND_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/features/org.apache.karaf.features.command 4.3.9 ${ORG_APACHE_KARAF_FEATURES_COMMAND_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.features.core lookupName=org.apache.karaf.features:org.apache.karaf.features.core
export ORG_APACHE_KARAF_FEATURES_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/features/org.apache.karaf.features.core 4.3.9 ${ORG_APACHE_KARAF_FEATURES_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.features.extension lookupName=org.apache.karaf.features:org.apache.karaf.features.extension
export ORG_APACHE_KARAF_FEATURES_EXTENSION_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/features/org.apache.karaf.features.extension 4.3.9 ${ORG_APACHE_KARAF_FEATURES_EXTENSION_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.jaas.boot lookupName=org.apache.karaf.jaas:org.apache.karaf.jaas.boot
export ORG_APACHE_KARAF_JAAS_BOOT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/jaas/org.apache.karaf.jaas.boot 4.3.9 ${ORG_APACHE_KARAF_JAAS_BOOT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.jaas.command lookupName=org.apache.karaf.jaas:org.apache.karaf.jaas.command
export ORG_APACHE_KARAF_JAAS_COMMAND_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/jaas/org.apache.karaf.jaas.command 4.3.9 ${ORG_APACHE_KARAF_JAAS_COMMAND_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.jaas.config lookupName=org.apache.karaf.jaas:org.apache.karaf.jaas.config
export ORG_APACHE_KARAF_JAAS_CONFIG_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/jaas/org.apache.karaf.jaas.config 4.3.9 ${ORG_APACHE_KARAF_JAAS_CONFIG_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.jaas.modules lookupName=org.apache.karaf.jaas:org.apache.karaf.jaas.modules
export ORG_APACHE_KARAF_JAAS_MODULES_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/jaas/org.apache.karaf.jaas.modules 4.3.9 ${ORG_APACHE_KARAF_JAAS_MODULES_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.kar.core lookupName=org.apache.karaf.kar:org.apache.karaf.kar.core
export ORG_APACHE_KARAF_KAR_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/kar/org.apache.karaf.kar.core 4.3.9 ${ORG_APACHE_KARAF_KAR_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.log.core lookupName=org.apache.karaf.log:org.apache.karaf.log.core
export ORG_APACHE_KARAF_LOG_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/log/org.apache.karaf.log.core 4.3.9 ${ORG_APACHE_KARAF_LOG_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.management.server lookupName=org.apache.karaf.management:org.apache.karaf.management.server
export ORG_APACHE_KARAF_MANAGEMENT_SERVER_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/management/org.apache.karaf.management.server 4.3.9 ${ORG_APACHE_KARAF_MANAGEMENT_SERVER_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.client lookupName=org.apache.karaf:org.apache.karaf.client
export ORG_APACHE_KARAF_CLIENT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/org.apache.karaf.client 4.3.9 ${ORG_APACHE_KARAF_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.package.core lookupName=org.apache.karaf.package:org.apache.karaf.package.core
export ORG_APACHE_KARAF_PACKAGE_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/package/org.apache.karaf.package.core 4.3.9 ${ORG_APACHE_KARAF_PACKAGE_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.scr.management lookupName=org.apache.karaf.scr:org.apache.karaf.scr.management
export ORG_APACHE_KARAF_SCR_MANAGEMENT_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/scr/org.apache.karaf.scr.management 4.3.9 ${ORG_APACHE_KARAF_SCR_MANAGEMENT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.scr.state lookupName=org.apache.karaf.scr:org.apache.karaf.scr.state
export ORG_APACHE_KARAF_SCR_STATE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/scr/org.apache.karaf.scr.state 4.3.9 ${ORG_APACHE_KARAF_SCR_STATE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.service.core lookupName=org.apache.karaf.service:org.apache.karaf.service.core
export ORG_APACHE_KARAF_SERVICE_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/service/org.apache.karaf.service.core 4.3.9 ${ORG_APACHE_KARAF_SERVICE_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.shell.commands lookupName=org.apache.karaf.shell:org.apache.karaf.shell.commands
export ORG_APACHE_KARAF_SHELL_COMMANDS_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/shell/org.apache.karaf.shell.commands 4.3.9 ${ORG_APACHE_KARAF_SHELL_COMMANDS_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.shell.core lookupName=org.apache.karaf.shell:org.apache.karaf.shell.core
export ORG_APACHE_KARAF_SHELL_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/shell/org.apache.karaf.shell.core 4.3.9 ${ORG_APACHE_KARAF_SHELL_CORE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.karaf.system.core lookupName=org.apache.karaf.system:org.apache.karaf.system.core
export ORG_APACHE_KARAF_SYSTEM_CORE_NEW_VERSION=4.3.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/karaf/system/org.apache.karaf.system.core 4.3.9 ${ORG_APACHE_KARAF_SYSTEM_CORE_NEW_VERSION}

# renovate: datasource=maven depName=archetype-catalog lookupName=org.apache.maven.archetype:archetype-catalog
export ARCHETYPE_CATALOG_NEW_VERSION=3.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/maven/archetype/archetype-catalog 3.2.0 ${ARCHETYPE_CATALOG_NEW_VERSION}

# renovate: datasource=maven depName=indexer-reader lookupName=org.apache.maven.indexer:indexer-reader
export INDEXER_READER_NEW_VERSION=5.1.2-202109
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/maven/indexer/indexer-reader 5.1.2-202109 ${INDEXER_READER_NEW_VERSION}

# renovate: datasource=maven depName=maven-model lookupName=org.apache.maven:maven-model
export MAVEN_MODEL_NEW_VERSION=3.9.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/maven/maven-model 3.9.5 ${MAVEN_MODEL_NEW_VERSION}

# renovate: datasource=maven depName=maven-repository-metadata lookupName=org.apache.maven:maven-repository-metadata
export MAVEN_REPOSITORY_METADATA_NEW_VERSION=3.9.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/maven/maven-repository-metadata 3.9.5 ${MAVEN_REPOSITORY_METADATA_NEW_VERSION}

# renovate: datasource=maven depName=xmlsec lookupName=org.apache.santuario:xmlsec
export XMLSEC_NEW_VERSION=2.3.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/santuario/xmlsec 2.3.4 ${XMLSEC_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.servicemix.bundles.aopalliance lookupName=org.apache.servicemix.bundles:org.apache.servicemix.bundles.aopalliance
export ORG_APACHE_SERVICEMIX_BUNDLES_AOPALLIANCE_NEW_VERSION=1.0_6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/servicemix/bundles/org.apache.servicemix.bundles.aopalliance 1.0_6 ${ORG_APACHE_SERVICEMIX_BUNDLES_AOPALLIANCE_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.servicemix.bundles.javax-inject lookupName=org.apache.servicemix.bundles:org.apache.servicemix.bundles.javax-inject
export ORG_APACHE_SERVICEMIX_BUNDLES_JAVAX_INJECT_NEW_VERSION=1_2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/servicemix/bundles/org.apache.servicemix.bundles.javax-inject 1_2 ${ORG_APACHE_SERVICEMIX_BUNDLES_JAVAX_INJECT_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.servicemix.bundles.xpp3 lookupName=org.apache.servicemix.bundles:org.apache.servicemix.bundles.xpp3
export ORG_APACHE_SERVICEMIX_BUNDLES_XPP3_NEW_VERSION=1.1.4c_7
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/servicemix/bundles/org.apache.servicemix.bundles.xpp3 1.1.4c_7 ${ORG_APACHE_SERVICEMIX_BUNDLES_XPP3_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.servicemix.specs.activation-api-1.1 lookupName=org.apache.servicemix.specs:org.apache.servicemix.specs.activation-api-1.1
export ORG_APACHE_SERVICEMIX_SPECS_ACTIVATION_API_1_1_NEW_VERSION=2.9.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/servicemix/specs/org.apache.servicemix.specs.activation-api-1.1 2.9.0 ${ORG_APACHE_SERVICEMIX_SPECS_ACTIVATION_API_1_1_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.servicemix.specs.jaxb-api-2.2 lookupName=org.apache.servicemix.specs:org.apache.servicemix.specs.jaxb-api-2.2
export ORG_APACHE_SERVICEMIX_SPECS_JAXB_API_2_2_NEW_VERSION=2.9.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/servicemix/specs/org.apache.servicemix.specs.jaxb-api-2.2 2.9.0 ${ORG_APACHE_SERVICEMIX_SPECS_JAXB_API_2_2_NEW_VERSION}

# renovate: datasource=maven depName=shiro-core lookupName=org.apache.shiro:shiro-core
export SHIRO_CORE_NEW_VERSION=1.13.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/shiro/shiro-core 1.13.0 ${SHIRO_CORE_NEW_VERSION}

# renovate: datasource=maven depName=shiro-guice lookupName=org.apache.shiro:shiro-guice
export SHIRO_GUICE_NEW_VERSION=1.13.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/shiro/shiro-guice 1.13.0 ${SHIRO_GUICE_NEW_VERSION}

# renovate: datasource=maven depName=shiro-web lookupName=org.apache.shiro:shiro-web
export SHIRO_WEB_NEW_VERSION=1.13.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/shiro/shiro-web 1.13.0 ${SHIRO_WEB_NEW_VERSION}

# renovate: datasource=maven depName=org.apache.sling.commons.johnzon lookupName=org.apache.sling:org.apache.sling.commons.johnzon
export ORG_APACHE_SLING_COMMONS_JOHNZON_NEW_VERSION=1.2.14
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/sling/org.apache.sling.commons.johnzon 1.2.14 ${ORG_APACHE_SLING_COMMONS_JOHNZON_NEW_VERSION}

# Skipping package: org.apache.tika:tika-core
# renovate: datasource=maven depName=velocity-engine-core lookupName=org.apache.velocity:velocity-engine-core
export VELOCITY_ENGINE_CORE_NEW_VERSION=2.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/apache/velocity/velocity-engine-core 2.3 ${VELOCITY_ENGINE_CORE_NEW_VERSION}

# renovate: datasource=maven depName=checker-qual lookupName=org.checkerframework:checker-qual
export CHECKER_QUAL_NEW_VERSION=3.42.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/checkerframework/checker-qual 3.42.0 ${CHECKER_QUAL_NEW_VERSION}

# renovate: datasource=maven depName=groovy-astbuilder lookupName=org.codehaus.groovy:groovy-astbuilder
export GROOVY_ASTBUILDER_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-astbuilder 3.0.19 ${GROOVY_ASTBUILDER_NEW_VERSION}

# renovate: datasource=maven depName=groovy-cli-commons lookupName=org.codehaus.groovy:groovy-cli-commons
export GROOVY_CLI_COMMONS_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-cli-commons 3.0.19 ${GROOVY_CLI_COMMONS_NEW_VERSION}

# renovate: datasource=maven depName=groovy-datetime lookupName=org.codehaus.groovy:groovy-datetime
export GROOVY_DATETIME_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-datetime 3.0.19 ${GROOVY_DATETIME_NEW_VERSION}

# renovate: datasource=maven depName=groovy-dateutil lookupName=org.codehaus.groovy:groovy-dateutil
export GROOVY_DATEUTIL_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-dateutil 3.0.19 ${GROOVY_DATEUTIL_NEW_VERSION}

# renovate: datasource=maven depName=groovy-jmx lookupName=org.codehaus.groovy:groovy-jmx
export GROOVY_JMX_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-jmx 3.0.19 ${GROOVY_JMX_NEW_VERSION}

# renovate: datasource=maven depName=groovy-json lookupName=org.codehaus.groovy:groovy-json
export GROOVY_JSON_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-json 3.0.19 ${GROOVY_JSON_NEW_VERSION}

# renovate: datasource=maven depName=groovy-jsr223 lookupName=org.codehaus.groovy:groovy-jsr223
export GROOVY_JSR223_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-jsr223 3.0.19 ${GROOVY_JSR223_NEW_VERSION}

# renovate: datasource=maven depName=groovy-macro lookupName=org.codehaus.groovy:groovy-macro
export GROOVY_MACRO_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-macro 3.0.19 ${GROOVY_MACRO_NEW_VERSION}

# renovate: datasource=maven depName=groovy-nio lookupName=org.codehaus.groovy:groovy-nio
export GROOVY_NIO_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-nio 3.0.19 ${GROOVY_NIO_NEW_VERSION}

# renovate: datasource=maven depName=groovy-sql lookupName=org.codehaus.groovy:groovy-sql
export GROOVY_SQL_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-sql 3.0.19 ${GROOVY_SQL_NEW_VERSION}

# renovate: datasource=maven depName=groovy-templates lookupName=org.codehaus.groovy:groovy-templates
export GROOVY_TEMPLATES_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-templates 3.0.19 ${GROOVY_TEMPLATES_NEW_VERSION}

# renovate: datasource=maven depName=groovy-xml lookupName=org.codehaus.groovy:groovy-xml
export GROOVY_XML_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy-xml 3.0.19 ${GROOVY_XML_NEW_VERSION}

# renovate: datasource=maven depName=groovy lookupName=org.codehaus.groovy:groovy
export GROOVY_NEW_VERSION=3.0.19
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/groovy/groovy 3.0.19 ${GROOVY_NEW_VERSION}

# renovate: datasource=maven depName=animal-sniffer-annotations lookupName=org.codehaus.mojo:animal-sniffer-annotations
export ANIMAL_SNIFFER_ANNOTATIONS_NEW_VERSION=1.21
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/mojo/animal-sniffer-annotations 1.21 ${ANIMAL_SNIFFER_ANNOTATIONS_NEW_VERSION}

# renovate: datasource=maven depName=plexus-interpolation lookupName=org.codehaus.plexus:plexus-interpolation
export PLEXUS_INTERPOLATION_NEW_VERSION=1.27
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/plexus/plexus-interpolation 1.27 ${PLEXUS_INTERPOLATION_NEW_VERSION}

# renovate: datasource=maven depName=plexus-utils lookupName=org.codehaus.plexus:plexus-utils
export PLEXUS_UTILS_NEW_VERSION=3.5.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/codehaus/plexus/plexus-utils 3.5.1 ${PLEXUS_UTILS_NEW_VERSION}

# renovate: datasource=maven depName=conscrypt-openjdk-uber lookupName=org.conscrypt:conscrypt-openjdk-uber
export CONSCRYPT_OPENJDK_UBER_NEW_VERSION=2.5.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/conscrypt/conscrypt-openjdk-uber 2.5.2 ${CONSCRYPT_OPENJDK_UBER_NEW_VERSION}

# renovate: datasource=maven depName=core4j lookupName=org.core4j:core4j
export CORE4J_NEW_VERSION=0.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/core4j/core4j 0.5 ${CORE4J_NEW_VERSION}

# renovate: datasource=maven depName=cyclonedx-core-java lookupName=org.cyclonedx:cyclonedx-core-java
export CYCLONEDX_CORE_JAVA_NEW_VERSION=7.3.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/cyclonedx/cyclonedx-core-java 7.3.2 ${CYCLONEDX_CORE_JAVA_NEW_VERSION}

# renovate: datasource=maven depName=aether-api lookupName=org.eclipse.aether:aether-api
export AETHER_API_NEW_VERSION=1.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/eclipse/aether/aether-api 1.1.0 ${AETHER_API_NEW_VERSION}

# renovate: datasource=maven depName=aether-spi lookupName=org.eclipse.aether:aether-spi
export AETHER_SPI_NEW_VERSION=1.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/eclipse/aether/aether-spi 1.1.0 ${AETHER_SPI_NEW_VERSION}

# renovate: datasource=maven depName=aether-util lookupName=org.eclipse.aether:aether-util
export AETHER_UTIL_NEW_VERSION=1.1.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/eclipse/aether/aether-util 1.1.0 ${AETHER_UTIL_NEW_VERSION}

# Skipping package (group ignored): org.eclipse.jetty:jetty-client
# Skipping package (group ignored): org.eclipse.jetty:jetty-continuation
# Skipping package (group ignored): org.eclipse.jetty:jetty-deploy
# Skipping package (group ignored): org.eclipse.jetty:jetty-http
# Skipping package (group ignored): org.eclipse.jetty:jetty-io
# Skipping package (group ignored): org.eclipse.jetty:jetty-jmx
# Skipping package (group ignored): org.eclipse.jetty:jetty-proxy
# Skipping package (group ignored): org.eclipse.jetty:jetty-rewrite
# Skipping package (group ignored): org.eclipse.jetty:jetty-security
# Skipping package (group ignored): org.eclipse.jetty:jetty-server
# Skipping package (group ignored): org.eclipse.jetty:jetty-servlet
# Skipping package (group ignored): org.eclipse.jetty:jetty-util-ajax
# Skipping package (group ignored): org.eclipse.jetty:jetty-util
# Skipping package (group ignored): org.eclipse.jetty:jetty-webapp
# Skipping package (group ignored): org.eclipse.jetty:jetty-xml
# renovate: datasource=maven depName=org.eclipse.osgi lookupName=org.eclipse.platform:org.eclipse.osgi
export ORG_ECLIPSE_OSGI_NEW_VERSION=3.17.200
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/eclipse/platform/org.eclipse.osgi 3.17.200 ${ORG_ECLIPSE_OSGI_NEW_VERSION}

# renovate: datasource=maven depName=org.eclipse.sisu.inject lookupName=org.eclipse.sisu:org.eclipse.sisu.inject
export ORG_ECLIPSE_SISU_INJECT_NEW_VERSION=0.9.0.M3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/eclipse/sisu/org.eclipse.sisu.inject 0.9.0.M3 ${ORG_ECLIPSE_SISU_INJECT_NEW_VERSION}

# renovate: datasource=maven depName=ehcache lookupName=org.ehcache:ehcache
export EHCACHE_NEW_VERSION=3.9.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/ehcache/ehcache 3.9.3 ${EHCACHE_NEW_VERSION}

# renovate: datasource=maven depName=flyway-core lookupName=org.flywaydb:flyway-core
export FLYWAY_CORE_NEW_VERSION=8.5.13
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/flywaydb/flyway-core 8.5.13 ${FLYWAY_CORE_NEW_VERSION}

# renovate: datasource=maven depName=freemarker lookupName=org.freemarker:freemarker
export FREEMARKER_NEW_VERSION=2.3.32
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/freemarker/freemarker 2.3.32 ${FREEMARKER_NEW_VERSION}

# renovate: datasource=maven depName=jansi lookupName=org.fusesource.jansi:jansi
export JANSI_NEW_VERSION=2.4.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/fusesource/jansi/jansi 2.4.0 ${JANSI_NEW_VERSION}

# renovate: datasource=maven depName=jakarta.el lookupName=org.glassfish:jakarta.el
export JAKARTA_EL_NEW_VERSION=3.0.4
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/glassfish/jakarta.el 3.0.4 ${JAKARTA_EL_NEW_VERSION}

# renovate: datasource=maven depName=HdrHistogram lookupName=org.hdrhistogram:HdrHistogram
export HDRHISTOGRAM_NEW_VERSION=2.2.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/hdrhistogram/HdrHistogram 2.2.1 ${HDRHISTOGRAM_NEW_VERSION}

# renovate: datasource=maven depName=hibernate-validator lookupName=org.hibernate.validator:hibernate-validator
export HIBERNATE_VALIDATOR_NEW_VERSION=6.2.0.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/hibernate/validator/hibernate-validator 6.2.0.Final ${HIBERNATE_VALIDATOR_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-atom-provider lookupName=org.jboss.resteasy:resteasy-atom-provider
export RESTEASY_ATOM_PROVIDER_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-atom-provider 3.15.6.Final ${RESTEASY_ATOM_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-client lookupName=org.jboss.resteasy:resteasy-client
export RESTEASY_CLIENT_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-client 3.15.6.Final ${RESTEASY_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-jackson2-provider lookupName=org.jboss.resteasy:resteasy-jackson2-provider
export RESTEASY_JACKSON2_PROVIDER_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-jackson2-provider 3.15.6.Final ${RESTEASY_JACKSON2_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-jaxb-provider lookupName=org.jboss.resteasy:resteasy-jaxb-provider
export RESTEASY_JAXB_PROVIDER_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-jaxb-provider 3.15.6.Final ${RESTEASY_JAXB_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-jaxrs lookupName=org.jboss.resteasy:resteasy-jaxrs
export RESTEASY_JAXRS_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-jaxrs 3.15.6.Final ${RESTEASY_JAXRS_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-multipart-provider lookupName=org.jboss.resteasy:resteasy-multipart-provider
export RESTEASY_MULTIPART_PROVIDER_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-multipart-provider 3.15.6.Final ${RESTEASY_MULTIPART_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=resteasy-validator-provider lookupName=org.jboss.resteasy:resteasy-validator-provider
export RESTEASY_VALIDATOR_PROVIDER_NEW_VERSION=3.15.6.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/resteasy/resteasy-validator-provider 3.15.6.Final ${RESTEASY_VALIDATOR_PROVIDER_NEW_VERSION}

# renovate: datasource=maven depName=jboss-jaxrs-api_2.1_spec lookupName=org.jboss.spec.javax.ws.rs:jboss-jaxrs-api_2.1_spec
export JBOSS_JAXRS_API_2_1_SPEC_NEW_VERSION=2.0.1.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/spec/javax/ws/rs/jboss-jaxrs-api_2.1_spec 2.0.1.Final ${JBOSS_JAXRS_API_2_1_SPEC_NEW_VERSION}

# renovate: datasource=maven depName=jboss-jaxb-api_2.3_spec lookupName=org.jboss.spec.javax.xml.bind:jboss-jaxb-api_2.3_spec
export JBOSS_JAXB_API_2_3_SPEC_NEW_VERSION=2.0.1.Final
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jboss/spec/javax/xml/bind/jboss-jaxb-api_2.3_spec 2.0.1.Final ${JBOSS_JAXB_API_2_3_SPEC_NEW_VERSION}

# renovate: datasource=maven depName=jdom2 lookupName=org.jdom:jdom2
export JDOM2_NEW_VERSION=2.0.6.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jdom/jdom2 2.0.6.1 ${JDOM2_NEW_VERSION}

# renovate: datasource=maven depName=jline lookupName=org.jline:jline
export JLINE_NEW_VERSION=3.21.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/jline/jline 3.21.0 ${JLINE_NEW_VERSION}

# renovate: datasource=maven depName=json lookupName=org.json:json
export JSON_NEW_VERSION=20231013
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/json/json 20231013 ${JSON_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-adapter-spi lookupName=org.keycloak:keycloak-adapter-spi
export KEYCLOAK_ADAPTER_SPI_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-adapter-spi 18.0.2 ${KEYCLOAK_ADAPTER_SPI_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-common lookupName=org.keycloak:keycloak-common
export KEYCLOAK_COMMON_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-common 18.0.2 ${KEYCLOAK_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-saml-adapter-api-public lookupName=org.keycloak:keycloak-saml-adapter-api-public
export KEYCLOAK_SAML_ADAPTER_API_PUBLIC_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-saml-adapter-api-public 18.0.2 ${KEYCLOAK_SAML_ADAPTER_API_PUBLIC_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-saml-adapter-core lookupName=org.keycloak:keycloak-saml-adapter-core
export KEYCLOAK_SAML_ADAPTER_CORE_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-saml-adapter-core 18.0.2 ${KEYCLOAK_SAML_ADAPTER_CORE_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-saml-core-public lookupName=org.keycloak:keycloak-saml-core-public
export KEYCLOAK_SAML_CORE_PUBLIC_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-saml-core-public 18.0.2 ${KEYCLOAK_SAML_CORE_PUBLIC_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-saml-core lookupName=org.keycloak:keycloak-saml-core
export KEYCLOAK_SAML_CORE_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-saml-core 18.0.2 ${KEYCLOAK_SAML_CORE_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-saml-servlet-filter-adapter lookupName=org.keycloak:keycloak-saml-servlet-filter-adapter
export KEYCLOAK_SAML_SERVLET_FILTER_ADAPTER_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-saml-servlet-filter-adapter 18.0.2 ${KEYCLOAK_SAML_SERVLET_FILTER_ADAPTER_NEW_VERSION}

# renovate: datasource=maven depName=keycloak-servlet-adapter-spi lookupName=org.keycloak:keycloak-servlet-adapter-spi
export KEYCLOAK_SERVLET_ADAPTER_SPI_NEW_VERSION=18.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/keycloak/keycloak-servlet-adapter-spi 18.0.2 ${KEYCLOAK_SERVLET_ADAPTER_SPI_NEW_VERSION}

# renovate: datasource=maven depName=mybatis lookupName=org.mybatis:mybatis
export MYBATIS_NEW_VERSION=3.5.15
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/mybatis/mybatis 3.5.15 ${MYBATIS_NEW_VERSION}

# renovate: datasource=maven depName=objenesis lookupName=org.objenesis:objenesis
export OBJENESIS_NEW_VERSION=3.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/objenesis/objenesis 3.3 ${OBJENESIS_NEW_VERSION}

# renovate: datasource=maven depName=pax-logging-api lookupName=org.ops4j.pax.logging:pax-logging-api
export PAX_LOGGING_API_NEW_VERSION=2.1.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/ops4j/pax/logging/pax-logging-api 2.1.3 ${PAX_LOGGING_API_NEW_VERSION}

# renovate: datasource=maven depName=pax-url-aether lookupName=org.ops4j.pax.url:pax-url-aether
export PAX_URL_AETHER_NEW_VERSION=2.6.12
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/ops4j/pax/url/pax-url-aether 2.6.12 ${PAX_URL_AETHER_NEW_VERSION}

# renovate: datasource=maven depName=pax-url-wrap lookupName=org.ops4j.pax.url:pax-url-wrap
export PAX_URL_WRAP_NEW_VERSION=2.6.12
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/ops4j/pax/url/pax-url-wrap 2.6.12 ${PAX_URL_WRAP_NEW_VERSION}

# renovate: datasource=maven depName=org.osgi.util.function lookupName=org.osgi:org.osgi.util.function
export ORG_OSGI_UTIL_FUNCTION_NEW_VERSION=1.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/osgi/org.osgi.util.function 1.2.0 ${ORG_OSGI_UTIL_FUNCTION_NEW_VERSION}

# renovate: datasource=maven depName=org.osgi.util.promise lookupName=org.osgi:org.osgi.util.promise
export ORG_OSGI_UTIL_PROMISE_NEW_VERSION=1.2.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/osgi/org.osgi.util.promise 1.2.0 ${ORG_OSGI_UTIL_PROMISE_NEW_VERSION}

# renovate: datasource=maven depName=encoder lookupName=org.owasp.encoder:encoder
export ENCODER_NEW_VERSION=1.2.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/owasp/encoder/encoder 1.2.3 ${ENCODER_NEW_VERSION}

# renovate: datasource=maven depName=postgresql lookupName=org.postgresql:postgresql
export POSTGRESQL_NEW_VERSION=42.7.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/postgresql/postgresql 42.7.2 ${POSTGRESQL_NEW_VERSION}

# renovate: datasource=maven depName=quartz lookupName=org.quartz-scheduler:quartz
export QUARTZ_NEW_VERSION=2.3.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/quartz-scheduler/quartz 2.3.2 ${QUARTZ_NEW_VERSION}

# renovate: datasource=maven depName=reactive-streams lookupName=org.reactivestreams:reactive-streams
export REACTIVE_STREAMS_NEW_VERSION=1.0.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/reactivestreams/reactive-streams 1.0.3 ${REACTIVE_STREAMS_NEW_VERSION}

# renovate: datasource=maven depName=redline lookupName=org.redline-rpm:redline
export REDLINE_NEW_VERSION=1.2.5
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/redline-rpm/redline 1.2.5 ${REDLINE_NEW_VERSION}

# renovate: datasource=maven depName=semver4j lookupName=org.semver4j:semver4j
export SEMVER4J_NEW_VERSION=4.2.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/semver4j/semver4j 4.2.1 ${SEMVER4J_NEW_VERSION}

# renovate: datasource=maven depName=snakeyaml-engine lookupName=org.snakeyaml:snakeyaml-engine
export SNAKEYAML_ENGINE_NEW_VERSION=2.6
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/snakeyaml/snakeyaml-engine 2.6 ${SNAKEYAML_ENGINE_NEW_VERSION}

# renovate: datasource=maven depName=goodies-common lookupName=org.sonatype.goodies:goodies-common
export GOODIES_COMMON_NEW_VERSION=2.3.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/goodies/goodies-common 2.3.8 ${GOODIES_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=goodies-i18n lookupName=org.sonatype.goodies:goodies-i18n
export GOODIES_I18N_NEW_VERSION=2.3.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/goodies/goodies-i18n 2.3.8 ${GOODIES_I18N_NEW_VERSION}

# renovate: datasource=maven depName=goodies-lifecycle lookupName=org.sonatype.goodies:goodies-lifecycle
export GOODIES_LIFECYCLE_NEW_VERSION=2.3.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/goodies/goodies-lifecycle 2.3.8 ${GOODIES_LIFECYCLE_NEW_VERSION}

# renovate: datasource=maven depName=package-url-java lookupName=org.sonatype.goodies:package-url-java
export PACKAGE_URL_JAVA_NEW_VERSION=1.1.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/goodies/package-url-java 1.1.1 ${PACKAGE_URL_JAVA_NEW_VERSION}

# renovate: datasource=maven depName=gossip-bootstrap lookupName=org.sonatype.gossip:gossip-bootstrap
export GOSSIP_BOOTSTRAP_NEW_VERSION=1.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/gossip/gossip-bootstrap 1.8 ${GOSSIP_BOOTSTRAP_NEW_VERSION}

# renovate: datasource=maven depName=gossip-support lookupName=org.sonatype.gossip:gossip-support
export GOSSIP_SUPPORT_NEW_VERSION=1.8
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/gossip/gossip-support 1.8 ${GOSSIP_SUPPORT_NEW_VERSION}

# renovate: datasource=maven depName=org.sonatype.nexus.bundles.elasticsearch lookupName=org.sonatype.nexus.bundles:org.sonatype.nexus.bundles.elasticsearch
export ORG_SONATYPE_NEXUS_BUNDLES_ELASTICSEARCH_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/bundles/org.sonatype.nexus.bundles.elasticsearch 3.76.0-03 ${ORG_SONATYPE_NEXUS_BUNDLES_ELASTICSEARCH_NEW_VERSION}

# renovate: datasource=maven depName=nexus-audit lookupName=org.sonatype.nexus:nexus-audit
export NEXUS_AUDIT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-audit 3.76.0-03 ${NEXUS_AUDIT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-base lookupName=org.sonatype.nexus:nexus-base
export NEXUS_BASE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-base 3.76.0-03 ${NEXUS_BASE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-api lookupName=org.sonatype.nexus:nexus-blobstore-api
export NEXUS_BLOBSTORE_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-blobstore-api 3.76.0-03 ${NEXUS_BLOBSTORE_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-file lookupName=org.sonatype.nexus:nexus-blobstore-file
export NEXUS_BLOBSTORE_FILE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-blobstore-file 3.76.0-03 ${NEXUS_BLOBSTORE_FILE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore lookupName=org.sonatype.nexus:nexus-blobstore
export NEXUS_BLOBSTORE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-blobstore 3.76.0-03 ${NEXUS_BLOBSTORE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-bootstrap lookupName=org.sonatype.nexus:nexus-bootstrap
export NEXUS_BOOTSTRAP_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-bootstrap 3.76.0-03 ${NEXUS_BOOTSTRAP_NEW_VERSION}

# renovate: datasource=maven depName=nexus-cache lookupName=org.sonatype.nexus:nexus-cache
export NEXUS_CACHE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-cache 3.76.0-03 ${NEXUS_CACHE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-capability lookupName=org.sonatype.nexus:nexus-capability
export NEXUS_CAPABILITY_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-capability 3.76.0-03 ${NEXUS_CAPABILITY_NEW_VERSION}

# renovate: datasource=maven depName=nexus-cleanup-config lookupName=org.sonatype.nexus:nexus-cleanup-config
export NEXUS_CLEANUP_CONFIG_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-cleanup-config 3.76.0-03 ${NEXUS_CLEANUP_CONFIG_NEW_VERSION}

# renovate: datasource=maven depName=nexus-cleanup lookupName=org.sonatype.nexus:nexus-cleanup
export NEXUS_CLEANUP_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-cleanup 3.76.0-03 ${NEXUS_CLEANUP_NEW_VERSION}

# renovate: datasource=maven depName=nexus-commands lookupName=org.sonatype.nexus:nexus-commands
export NEXUS_COMMANDS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-commands 3.76.0-03 ${NEXUS_COMMANDS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-common lookupName=org.sonatype.nexus:nexus-common
export NEXUS_COMMON_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-common 3.76.0-03 ${NEXUS_COMMON_NEW_VERSION}

# renovate: datasource=maven depName=nexus-core lookupName=org.sonatype.nexus:nexus-core
export NEXUS_CORE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-core 3.76.0-03 ${NEXUS_CORE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-crypto lookupName=org.sonatype.nexus:nexus-crypto
export NEXUS_CRYPTO_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-crypto 3.76.0-03 ${NEXUS_CRYPTO_NEW_VERSION}

# renovate: datasource=maven depName=nexus-datastore-api lookupName=org.sonatype.nexus:nexus-datastore-api
export NEXUS_DATASTORE_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-datastore-api 3.76.0-03 ${NEXUS_DATASTORE_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-datastore-mybatis lookupName=org.sonatype.nexus:nexus-datastore-mybatis
export NEXUS_DATASTORE_MYBATIS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-datastore-mybatis 3.76.0-03 ${NEXUS_DATASTORE_MYBATIS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-datastore lookupName=org.sonatype.nexus:nexus-datastore
export NEXUS_DATASTORE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-datastore 3.76.0-03 ${NEXUS_DATASTORE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-distributed-event-service-api lookupName=org.sonatype.nexus:nexus-distributed-event-service-api
export NEXUS_DISTRIBUTED_EVENT_SERVICE_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-distributed-event-service-api 3.76.0-03 ${NEXUS_DISTRIBUTED_EVENT_SERVICE_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-elasticsearch lookupName=org.sonatype.nexus:nexus-elasticsearch
export NEXUS_ELASTICSEARCH_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-elasticsearch 3.76.0-03 ${NEXUS_ELASTICSEARCH_NEW_VERSION}

# renovate: datasource=maven depName=nexus-email lookupName=org.sonatype.nexus:nexus-email
export NEXUS_EMAIL_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-email 3.76.0-03 ${NEXUS_EMAIL_NEW_VERSION}

# renovate: datasource=maven depName=nexus-extdirect lookupName=org.sonatype.nexus:nexus-extdirect
export NEXUS_EXTDIRECT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-extdirect 3.76.0-03 ${NEXUS_EXTDIRECT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-extender lookupName=org.sonatype.nexus:nexus-extender
export NEXUS_EXTENDER_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-extender 3.76.0-03 ${NEXUS_EXTENDER_NEW_VERSION}

# renovate: datasource=maven depName=nexus-features lookupName=org.sonatype.nexus:nexus-features
export NEXUS_FEATURES_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-features 3.76.0-03 ${NEXUS_FEATURES_NEW_VERSION}

# renovate: datasource=maven depName=nexus-formfields lookupName=org.sonatype.nexus:nexus-formfields
export NEXUS_FORMFIELDS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-formfields 3.76.0-03 ${NEXUS_FORMFIELDS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-guice-servlet lookupName=org.sonatype.nexus:nexus-guice-servlet
export NEXUS_GUICE_SERVLET_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-guice-servlet 3.76.0-03 ${NEXUS_GUICE_SERVLET_NEW_VERSION}

# renovate: datasource=maven depName=nexus-httpclient lookupName=org.sonatype.nexus:nexus-httpclient
export NEXUS_HTTPCLIENT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-httpclient 3.76.0-03 ${NEXUS_HTTPCLIENT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-jmx lookupName=org.sonatype.nexus:nexus-jmx
export NEXUS_JMX_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-jmx 3.76.0-03 ${NEXUS_JMX_NEW_VERSION}

# renovate: datasource=maven depName=nexus-main lookupName=org.sonatype.nexus:nexus-main
export NEXUS_MAIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-main 3.76.0-03 ${NEXUS_MAIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-mime lookupName=org.sonatype.nexus:nexus-mime
export NEXUS_MIME_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-mime 3.76.0-03 ${NEXUS_MIME_NEW_VERSION}

# renovate: datasource=maven depName=nexus-oss-edition lookupName=org.sonatype.nexus:nexus-oss-edition
export NEXUS_OSS_EDITION_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-oss-edition 3.76.0-03 ${NEXUS_OSS_EDITION_NEW_VERSION}

# renovate: datasource=maven depName=nexus-pax-logging lookupName=org.sonatype.nexus:nexus-pax-logging
export NEXUS_PAX_LOGGING_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-pax-logging 3.76.0-03 ${NEXUS_PAX_LOGGING_NEW_VERSION}

# renovate: datasource=maven depName=nexus-plugin-api lookupName=org.sonatype.nexus:nexus-plugin-api
export NEXUS_PLUGIN_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-plugin-api 3.76.0-03 ${NEXUS_PLUGIN_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-quartz lookupName=org.sonatype.nexus:nexus-quartz
export NEXUS_QUARTZ_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-quartz 3.76.0-03 ${NEXUS_QUARTZ_NEW_VERSION}

# renovate: datasource=maven depName=nexus-rapture lookupName=org.sonatype.nexus:nexus-rapture
export NEXUS_RAPTURE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-rapture 3.76.0-03 ${NEXUS_RAPTURE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-config lookupName=org.sonatype.nexus:nexus-repository-config
export NEXUS_REPOSITORY_CONFIG_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-repository-config 3.76.0-03 ${NEXUS_REPOSITORY_CONFIG_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-content lookupName=org.sonatype.nexus:nexus-repository-content
export NEXUS_REPOSITORY_CONTENT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-repository-content 3.76.0-03 ${NEXUS_REPOSITORY_CONTENT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-services lookupName=org.sonatype.nexus:nexus-repository-services
export NEXUS_REPOSITORY_SERVICES_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-repository-services 3.76.0-03 ${NEXUS_REPOSITORY_SERVICES_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-view lookupName=org.sonatype.nexus:nexus-repository-view
export NEXUS_REPOSITORY_VIEW_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-repository-view 3.76.0-03 ${NEXUS_REPOSITORY_VIEW_NEW_VERSION}

# renovate: datasource=maven depName=nexus-rest-client lookupName=org.sonatype.nexus:nexus-rest-client
export NEXUS_REST_CLIENT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-rest-client 3.76.0-03 ${NEXUS_REST_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-rest-jackson2 lookupName=org.sonatype.nexus:nexus-rest-jackson2
export NEXUS_REST_JACKSON2_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-rest-jackson2 3.76.0-03 ${NEXUS_REST_JACKSON2_NEW_VERSION}

# renovate: datasource=maven depName=nexus-rest lookupName=org.sonatype.nexus:nexus-rest
export NEXUS_REST_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-rest 3.76.0-03 ${NEXUS_REST_NEW_VERSION}

# renovate: datasource=maven depName=nexus-scheduling lookupName=org.sonatype.nexus:nexus-scheduling
export NEXUS_SCHEDULING_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-scheduling 3.76.0-03 ${NEXUS_SCHEDULING_NEW_VERSION}

# renovate: datasource=maven depName=nexus-script lookupName=org.sonatype.nexus:nexus-script
export NEXUS_SCRIPT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-script 3.76.0-03 ${NEXUS_SCRIPT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-security lookupName=org.sonatype.nexus:nexus-security
export NEXUS_SECURITY_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-security 3.76.0-03 ${NEXUS_SECURITY_NEW_VERSION}

# renovate: datasource=maven depName=nexus-selector lookupName=org.sonatype.nexus:nexus-selector
export NEXUS_SELECTOR_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-selector 3.76.0-03 ${NEXUS_SELECTOR_NEW_VERSION}

# renovate: datasource=maven depName=nexus-servlet lookupName=org.sonatype.nexus:nexus-servlet
export NEXUS_SERVLET_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-servlet 3.76.0-03 ${NEXUS_SERVLET_NEW_VERSION}

# renovate: datasource=maven depName=nexus-siesta lookupName=org.sonatype.nexus:nexus-siesta
export NEXUS_SIESTA_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-siesta 3.76.0-03 ${NEXUS_SIESTA_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ssl lookupName=org.sonatype.nexus:nexus-ssl
export NEXUS_SSL_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-ssl 3.76.0-03 ${NEXUS_SSL_NEW_VERSION}

# renovate: datasource=maven depName=nexus-supportzip-api lookupName=org.sonatype.nexus:nexus-supportzip-api
export NEXUS_SUPPORTZIP_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-supportzip-api 3.76.0-03 ${NEXUS_SUPPORTZIP_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-swagger lookupName=org.sonatype.nexus:nexus-swagger
export NEXUS_SWAGGER_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-swagger 3.76.0-03 ${NEXUS_SWAGGER_NEW_VERSION}

# renovate: datasource=maven depName=nexus-task-logging lookupName=org.sonatype.nexus:nexus-task-logging
export NEXUS_TASK_LOGGING_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-task-logging 3.76.0-03 ${NEXUS_TASK_LOGGING_NEW_VERSION}

# renovate: datasource=maven depName=nexus-thread lookupName=org.sonatype.nexus:nexus-thread
export NEXUS_THREAD_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-thread 3.76.0-03 ${NEXUS_THREAD_NEW_VERSION}

# renovate: datasource=maven depName=nexus-transaction lookupName=org.sonatype.nexus:nexus-transaction
export NEXUS_TRANSACTION_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-transaction 3.76.0-03 ${NEXUS_TRANSACTION_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ui-plugin lookupName=org.sonatype.nexus:nexus-ui-plugin
export NEXUS_UI_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-ui-plugin 3.76.0-03 ${NEXUS_UI_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-upgrade lookupName=org.sonatype.nexus:nexus-upgrade
export NEXUS_UPGRADE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-upgrade 3.76.0-03 ${NEXUS_UPGRADE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-validation lookupName=org.sonatype.nexus:nexus-validation
export NEXUS_VALIDATION_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-validation 3.76.0-03 ${NEXUS_VALIDATION_NEW_VERSION}

# renovate: datasource=maven depName=nexus-webhooks lookupName=org.sonatype.nexus:nexus-webhooks
export NEXUS_WEBHOOKS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-webhooks 3.76.0-03 ${NEXUS_WEBHOOKS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-webresources-api lookupName=org.sonatype.nexus:nexus-webresources-api
export NEXUS_WEBRESOURCES_API_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/nexus-webresources-api 3.76.0-03 ${NEXUS_WEBRESOURCES_API_NEW_VERSION}

# renovate: datasource=maven depName=nexus-audit-plugin lookupName=org.sonatype.nexus.plugins:nexus-audit-plugin
export NEXUS_AUDIT_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-audit-plugin 3.76.0-03 ${NEXUS_AUDIT_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-s3 lookupName=org.sonatype.nexus.plugins:nexus-blobstore-s3
export NEXUS_BLOBSTORE_S3_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-blobstore-s3 3.76.0-03 ${NEXUS_BLOBSTORE_S3_NEW_VERSION}

# renovate: datasource=maven depName=nexus-blobstore-tasks lookupName=org.sonatype.nexus.plugins:nexus-blobstore-tasks
export NEXUS_BLOBSTORE_TASKS_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-blobstore-tasks 3.76.0-03 ${NEXUS_BLOBSTORE_TASKS_NEW_VERSION}

# renovate: datasource=maven depName=nexus-coreui-plugin lookupName=org.sonatype.nexus.plugins:nexus-coreui-plugin
export NEXUS_COREUI_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-coreui-plugin 3.76.0-03 ${NEXUS_COREUI_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-default-role-plugin lookupName=org.sonatype.nexus.plugins:nexus-default-role-plugin
export NEXUS_DEFAULT_ROLE_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-default-role-plugin 3.76.0-03 ${NEXUS_DEFAULT_ROLE_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-onboarding-plugin lookupName=org.sonatype.nexus.plugins:nexus-onboarding-plugin
export NEXUS_ONBOARDING_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-onboarding-plugin 3.76.0-03 ${NEXUS_ONBOARDING_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-apt lookupName=org.sonatype.nexus.plugins:nexus-repository-apt
export NEXUS_REPOSITORY_APT_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-repository-apt 3.76.0-03 ${NEXUS_REPOSITORY_APT_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-httpbridge lookupName=org.sonatype.nexus.plugins:nexus-repository-httpbridge
export NEXUS_REPOSITORY_HTTPBRIDGE_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-repository-httpbridge 3.76.0-03 ${NEXUS_REPOSITORY_HTTPBRIDGE_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-maven lookupName=org.sonatype.nexus.plugins:nexus-repository-maven
export NEXUS_REPOSITORY_MAVEN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-repository-maven 3.76.0-03 ${NEXUS_REPOSITORY_MAVEN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-repository-raw lookupName=org.sonatype.nexus.plugins:nexus-repository-raw
export NEXUS_REPOSITORY_RAW_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-repository-raw 3.76.0-03 ${NEXUS_REPOSITORY_RAW_NEW_VERSION}

# renovate: datasource=maven depName=nexus-script-plugin lookupName=org.sonatype.nexus.plugins:nexus-script-plugin
export NEXUS_SCRIPT_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-script-plugin 3.76.0-03 ${NEXUS_SCRIPT_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-ssl-plugin lookupName=org.sonatype.nexus.plugins:nexus-ssl-plugin
export NEXUS_SSL_PLUGIN_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-ssl-plugin 3.76.0-03 ${NEXUS_SSL_PLUGIN_NEW_VERSION}

# renovate: datasource=maven depName=nexus-task-log-cleanup lookupName=org.sonatype.nexus.plugins:nexus-task-log-cleanup
export NEXUS_TASK_LOG_CLEANUP_NEW_VERSION=3.76.0-03
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/nexus/plugins/nexus-task-log-cleanup 3.76.0-03 ${NEXUS_TASK_LOG_CLEANUP_NEW_VERSION}

# renovate: datasource=maven depName=ossindex-service-api lookupName=org.sonatype.ossindex:ossindex-service-api
export OSSINDEX_SERVICE_API_NEW_VERSION=1.3.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/ossindex/ossindex-service-api 1.3.0 ${OSSINDEX_SERVICE_API_NEW_VERSION}

# renovate: datasource=maven depName=ossindex-service-client lookupName=org.sonatype.ossindex:ossindex-service-client
export OSSINDEX_SERVICE_CLIENT_NEW_VERSION=1.3.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/ossindex/ossindex-service-client 1.3.0 ${OSSINDEX_SERVICE_CLIENT_NEW_VERSION}

# renovate: datasource=maven depName=sisu-odata4j lookupName=org.sonatype.sisu:sisu-odata4j
export SISU_ODATA4J_NEW_VERSION=0.0.7
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/sonatype/sisu/sisu-odata4j 0.0.7 ${SISU_ODATA4J_NEW_VERSION}

# renovate: datasource=maven depName=java-spdx-library lookupName=org.spdx:java-spdx-library
export JAVA_SPDX_LIBRARY_NEW_VERSION=1.1.7
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/spdx/java-spdx-library 1.1.7 ${JAVA_SPDX_LIBRARY_NEW_VERSION}

# renovate: datasource=maven depName=spdx-jackson-store lookupName=org.spdx:spdx-jackson-store
export SPDX_JACKSON_STORE_NEW_VERSION=1.1.7
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/spdx/spdx-jackson-store 1.1.7 ${SPDX_JACKSON_STORE_NEW_VERSION}

# renovate: datasource=maven depName=threetenbp lookupName=org.threeten:threetenbp
export THREETENBP_NEW_VERSION=1.6.9
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/threeten/threetenbp 1.6.9 ${THREETENBP_NEW_VERSION}

# renovate: datasource=maven depName=tomlj lookupName=org.tomlj:tomlj
export TOMLJ_NEW_VERSION=1.0.0
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/tomlj/tomlj 1.0.0 ${TOMLJ_NEW_VERSION}

# renovate: datasource=maven depName=xz lookupName=org.tukaani:xz
export XZ_NEW_VERSION=1.10
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/tukaani/xz 1.10 ${XZ_NEW_VERSION}

# renovate: datasource=maven depName=snakeyaml lookupName=org.yaml:snakeyaml
export SNAKEYAML_NEW_VERSION=2.3
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME org/yaml/snakeyaml 2.3 ${SNAKEYAML_NEW_VERSION}

# renovate: datasource=maven depName=alphanumeric-comparator lookupName=se.sawano.java:alphanumeric-comparator
export ALPHANUMERIC_COMPARATOR_NEW_VERSION=1.4.1
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME se/sawano/java/alphanumeric-comparator 1.4.1 ${ALPHANUMERIC_COMPARATOR_NEW_VERSION}

# renovate: datasource=maven depName=sysout-over-slf4j lookupName=uk.org.lidalia:sysout-over-slf4j
export SYSOUT_OVER_SLF4J_NEW_VERSION=1.0.2
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME uk/org/lidalia/sysout-over-slf4j 1.0.2 ${SYSOUT_OVER_SLF4J_NEW_VERSION}

# renovate: datasource=maven depName=xpp3_min lookupName=xpp3:xpp3_min
export XPP3_MIN_NEW_VERSION=1.1.4c
$NEXUS_HOME/scripts/replace.sh $NEXUS_HOME xpp3/xpp3_min 1.1.4c ${XPP3_MIN_NEW_VERSION}

