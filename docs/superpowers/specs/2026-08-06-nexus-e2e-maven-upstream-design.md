# Nexus E2E Maven Upstream Bundle Design

## Goal

Package every external Maven artifact required by the Nexus Maven E2E tests
inside the testing image. Provide a script that imports those artifacts into a
second, authenticated Nexus instance. The Nexus instance under test then uses
that second Nexus as the remote for its `maven-central` proxy repository.

The resulting flow must not require the Nexus instance under test to reach a
public Maven repository.

## Scope

This change covers:

- collecting the Maven dependencies and build plugins used by
  `testing/nexus-e2e/test_projects/maven/publish.xml` and `download.xml`;
- packaging the collected Maven2 repository layout in `testing/Containerfile`;
- importing the bundle into a Maven hosted repository on a second Nexus;
- configuring the tested Nexus proxy with an authenticated second-Nexus
  remote; and
- automated tests and an offline build verification for this workflow.

It does not make the testing image itself buildable without network access.
The image build may continue to download its existing OS packages, tools,
Python packages, and Maven artifacts from configured build-time sources.

## Architecture

The testing image contains a read-only Maven2 repository bundle at:

```text
/opt/nexus-e2e/maven-repository
```

It also exposes this executable:

```text
/usr/local/bin/import-maven-e2e-dependencies
```

The import script creates or reuses a Maven hosted repository on the upstream
Nexus and uploads the bundle while preserving every Maven2 relative path.

At test time, `test_maven_proxy` updates the tested Nexus repository named
`maven-central`. Its remote points to the hosted repository on the upstream
Nexus, and its HTTP client configuration contains Basic Authentication for
that upstream.

```text
testing image bundle
        |
        | import script (authenticated upload)
        v
upstream Nexus / repository/maven-e2e-external
        ^
        | authenticated proxy download
        |
tested Nexus / repository/maven-central
        ^
        | Maven E2E resolution
        |
test process
```

The upstream and tested Nexus instances are distinct. The workflow never
attempts to upload content directly into a Nexus proxy repository.

## Configuration Interface

The import script and Maven proxy test share these variables:

| Variable | Required | Default | Meaning |
| --- | --- | --- | --- |
| `MAVEN_UPSTREAM_URL` | For the new workflow | none | Base URL of the second Nexus |
| `MAVEN_UPSTREAM_REPOSITORY` | No | `maven-e2e-external` | Maven hosted repository name |
| `MAVEN_UPSTREAM_USERNAME` | Yes | none | Second Nexus username |
| `MAVEN_UPSTREAM_PASSWORD` | Yes | none | Second Nexus password |

URLs are normalized by removing a trailing slash before appending service or
repository paths. The upstream repository URL is:

```text
${MAVEN_UPSTREAM_URL}/repository/${MAVEN_UPSTREAM_REPOSITORY}/
```

Credentials must be supplied through environment variables or a silent
interactive prompt. The password is not accepted as a positional command-line
argument because process listings and shell history can expose it. The script
must not enable shell tracing or print authorization headers.

For backward compatibility, when `MAVEN_UPSTREAM_URL` is absent the tests keep
their current behavior: `MACVEN_MIRROR_REGISTRY`, including its historical
misspelling, overrides the existing anonymous mirror URL. The new variables
take precedence when present.

## Building the Maven Bundle

The bundle must be derived from actual E2E Maven lifecycles rather than a
manually maintained artifact list. The explicit business dependency is
`junit:junit:4.11`, with `org.hamcrest:hamcrest-core:1.3` transitively, but the
tests also require Maven lifecycle plugins and their dependency closures.

During the image build:

1. Create a new, empty Maven local repository dedicated to the bundle.
2. Use a build-time settings file whose mirror is the configured trusted Maven
   source.
3. Run `clean deploy` for `publish.xml` with deployment redirected to a local
   file repository. This exercises clean, compile, test, jar, install, and
   deploy plugin resolution without contacting a real Nexus.
4. Make the produced `com.nexus.test:test-publish:1.0-SNAPSHOT` available to
   `download.xml`, then run its `package` lifecycle.
5. Repeat the required lifecycles with Maven offline mode enabled and the same
   isolated repository. A failure proves that the dependency closure is
   incomplete and fails the image build.
6. Remove resolver-local state that must not be imported, including
   `_remote.repositories`, `*.lastUpdated`, and `resolver-status.properties`.
7. Copy the remaining Maven2 layout into
   `/opt/nexus-e2e/maven-repository` in the final image.

The E2E-generated `com.nexus.test:test-publish:1.0-SNAPSHOT` is not an external
dependency and must be excluded from the import bundle. It is created and
deployed by the hosted-repository E2E scenario itself.

Using the real lifecycles is preferred to relying only on
`dependency:go-offline`: `go-offline` can resolve unused reporting and
plugin-management content while missing dynamically selected runtime plugin
components such as a Surefire provider.

## Import Script Behavior

The script performs these phases:

1. Validate required configuration and the bundle directory.
2. Verify authentication against the upstream Nexus REST API.
3. Inspect the configured repository name.
4. If it does not exist, create a Maven hosted repository with `MIXED` version
   policy and `STRICT` layout policy.
5. If it exists, verify that it is a Maven hosted repository. Fail rather than
   uploading into a repository with a different format or type.
6. Traverse regular files under the bundle directory and upload each one with
   an authenticated HTTP PUT to its matching Maven2 path.
7. Verify representative artifacts through authenticated GET requests,
   including JUnit, Hamcrest, and selected lifecycle plugin POM/JAR files.
8. Print a summary containing the repository URL and uploaded, skipped, and
   failed file counts. Do not print credentials.

The default repository name is `maven-e2e-external`. Users can override it
with `MAVEN_UPSTREAM_REPOSITORY`.

The script is safe to rerun. Before uploading a path that already exists, it
compares the remote content digest with the bundled file. Equal content is
skipped. Different content is reported as a conflict and causes a nonzero exit
instead of overwriting an immutable or inconsistent artifact. HTTP 401 and 403
responses are reported as authentication or authorization failures without
including response headers that may contain sensitive information.

The existing image entrypoint remains unchanged so current BDD execution is
not disrupted. Users invoke the importer by overriding the container entrypoint
or by selecting the executable as the container command in their runtime.

## E2E Code Changes

`testing/nexus-e2e/conftest.py` exposes a typed upstream Maven configuration
fixture populated from the new environment variables.

`testing/nexus-e2e/libs/nexus_client.py` extends Maven proxy configuration to
accept optional upstream Basic Authentication. Authentication is serialized
into the Nexus REST request only when all new upstream settings are present.
The existing unauthenticated request shape remains unchanged for legacy runs.

`testing/nexus-e2e/test_maven_repo.py` selects the remote as follows:

1. When `MAVEN_UPSTREAM_URL` is set, compose the hosted repository URL from the
   new configuration and pass the upstream credentials to the proxy update.
2. Otherwise, preserve the current `MACVEN_MIRROR_REGISTRY` or default mirror
   behavior without upstream authentication.

The test still clears Maven's local repository before `test_maven_proxy` and
resolves through the tested Nexus. This proves that the tested Nexus can
authenticate to the second Nexus, proxy the Maven artifacts, and serve them to
the E2E client.

## Error Handling and Security

- Missing URL, username, or password causes an early, actionable error in the
  import workflow.
- Repository format/type mismatches fail before any upload.
- Network errors include the operation and sanitized target URL but no
  credentials or authorization headers.
- Temporary settings and response files are removed on exit.
- Shell tracing is prohibited in the importer.
- The bundle and importer are readable/executable by the non-root UID used by
  integration tests.
- No credentials are baked into the image, repository, logs, or generated
  bundle.

## Testing and Verification

Automated tests cover:

- default and overridden upstream repository names;
- URL normalization and repository URL composition;
- repository creation, compatible repository reuse, and incompatible
  repository rejection;
- authenticated Nexus proxy request generation;
- backward-compatible unauthenticated proxy request generation;
- upload success, identical-content skip, conflict, and authentication error;
- absence of password and authorization values in script output; and
- filtering resolver-local files and the E2E-generated SNAPSHOT from the
  bundle.

Image-build verification runs the required Maven lifecycles in offline mode.
Script integration verification uses a disposable HTTP test server or mock
Nexus API that checks request paths and authentication without requiring a
shared external Nexus.

A final manual acceptance run against two disposable Nexus instances performs:

1. Build the testing image.
2. Run the importer against the upstream Nexus.
3. Confirm the upstream hosted repository contains representative artifacts.
4. Run `test_maven_proxy` against the tested Nexus with the four upstream
   variables configured.
5. Confirm Maven resolved JUnit from the tested Nexus and that the tested
   Nexus cached the artifact from the authenticated upstream.

If disposable Nexus instances are unavailable locally, the automated test and
offline image-build evidence are required, and the two-Nexus acceptance run is
reported as outstanding rather than inferred to have passed.

## Compatibility and Non-Goals

- Existing callers that set only `MACVEN_MIRROR_REGISTRY` continue to work.
- The fixed tested-repository name `maven-central` remains unchanged.
- Existing image `ENTRYPOINT` and normal integration-test commands remain
  unchanged.
- This change does not import NPM or PyPI dependencies.
- This change does not modify Nexus blob stores or internal databases.
- This change does not create, modify, or deploy any real Nexus instance while
  building the image.
