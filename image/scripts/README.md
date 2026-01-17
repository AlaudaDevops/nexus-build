# JAR Analyzer Script

- `analyze-jars.sh` - Script to analyze JAR files in the Nexus tar package and generate a script to upgrade dependencies. This should be executed manually on a local machine and typically only needs to be run once.
- `upgrade-dependencies.sh` - Auto-generated script to update JAR versions in Nexus based on the analysis from `analyze-jars.sh`.
- `replace.sh` - Script used by `upgrade-dependencies.sh` to replace JAR files in the `system` directory of the Nexus installation with new versions.
- `replace-lib.sh` - Script used by `upgrade-dependencies.sh` to replace JAR files in the `lib` directory of the Nexus installation with new versions.
- `replace-jetty.sh` - Script to upgrade Jetty JAR files in the Nexus installation. Jetty upgrades require all components to be at the same version, so they are handled separately.
