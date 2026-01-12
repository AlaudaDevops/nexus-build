# Compliance Notes

- License scope: The repository content is provided under Apache License 2.0 (see LICENSE) with attribution details in NOTICE.
- Nexus binaries: Images pull Nexus Repository Manager from `NEXUS_DOWNLOAD_URL`; those binaries are governed by Sonatype commercial/EULA terms. Validate entitlement before building or redistributing images and keep a copy of the applicable EULA with any distribution.
- Elastic License: Some upstream components may be licensed under Elastic License 2.0; retain `image/ELASTIC-LICENSE-2.0.txt` in any derivative image and honor the prohibition on offering the software as a hosted or managed service.
- Notices in artifacts: When publishing container images, include `LICENSE`, `NOTICE`, `image/NOTICE`, and `image/ELASTIC-LICENSE-2.0.txt` in the image or distribution package to preserve upstream notices.
- Third-party inventory: If additional third-party JARs or plugins are added, document their licenses and notices alongside the image (e.g., in `image/NOTICE`), and ensure compatibility with redistribution policies.
