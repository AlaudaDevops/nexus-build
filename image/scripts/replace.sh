#!/bin/sh

# 检查参数
if [ "$#" -ne 4 ]; then
    echo "用法: $0 <NEXUS_HOME> <JAR_PATH> <OLD_VERSION> <NEW_VERSION>"
    echo "例如: $0 org/apache/commons/commons-compress 1.24.0 1.26.2"
    exit 1
fi

NEXUS_HOME="$1"
JAR_PATH="$2"
OLD_VERSION="$3"
NEW_VERSION="$4"

JAR_NAME=$(basename $JAR_PATH)

# 1. 下载新JAR
echo "下载新版本JAR $JAR_NAME-$NEW_VERSION.jar..."
mkdir -p $NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION
curl -L -o $NEXUS_HOME/system/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar \
  https://repo1.maven.org/maven2/$JAR_PATH/$NEW_VERSION/$JAR_NAME-$NEW_VERSION.jar


# 2. 更新配置文件中的版本引用
echo "更新配置文件 $JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION ..."
# 替换形式1: "commons-compress/1.24.0"
sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g" $NEXUS_HOME/etc/karaf/startup.properties
find $NEXUS_HOME/system/org/sonatype/nexus/assemblies -name "*.xml" | xargs sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g"
find $NEXUS_HOME/system/com/sonatype/nexus/assemblies -name "*.xml" | xargs sed -i "s|$JAR_NAME/$OLD_VERSION|$JAR_NAME/$NEW_VERSION|g"

# 替换形式2: "commons-compress-1.24.0.jar"
sed -i "s|$JAR_NAME-$OLD_VERSION.jar|$JAR_NAME-$NEW_VERSION.jar|g" $NEXUS_HOME/etc/karaf/startup.properties

# 3. 删除旧版本JAR
echo "删除旧版本JAR $JAR_PATH/$OLD_VERSION/$JAR_NAME-$OLD_VERSION.jar ..."
rm -rf $NEXUS_HOME/system/$JAR_PATH/$OLD_VERSION
