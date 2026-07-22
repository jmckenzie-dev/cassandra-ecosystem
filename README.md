<!--
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
-->

# Apache Cassandra Ecosystem

Companion projects for [Apache Cassandra®](https://cassandra.apache.org/), co-located in a
single repository so cross-cutting changes can be made, reviewed, tested, and released as one
unit. This repository was created per [CEP-63](https://cwiki.apache.org/confluence/display/CASSANDRA/CEP-63)
by consolidating the former `cassandra-analytics` and `cassandra-sidecar` repositories.

## What lives here

| Project | Directory | What it is | Docs |
|---|---|---|---|
| **Analytics** | [`analytics/`](analytics/) | Spark bulk reader/writer connector for Cassandra (usable against non-Cassandra sources such as S3), the version-bridge layer, Spark/Avro converters, and the CDC implementation. | [README_ANALYTICS.md](README_ANALYTICS.md) |
| **Sidecar** | [`sidecar/`](sidecar/) | Operational sidecar for Cassandra (health, rolling operations, streaming, CDC-to-Kafka) plus its client family and version adapters. | [README_SIDECAR.md](README_SIDECAR.md) |

Each project is an **independent Gradle build** rooted in its own directory (its own
`settings.gradle`, `build.gradle`, and gradle wrapper). Nothing about the individual builds
changed as part of the merge, and today they still consume each other's *published* artifacts
(`0.4.0`) rather than in-repo project dependencies. Breaking the remaining circular dependency
(de-duplicating the Sidecar client, re-homing CDC) is a follow-up, not part of this initial
consolidation.

## Inclusion criteria (please read before proposing a new project)

To keep this repository focused and prevent it from becoming a "junk drawer", a new top-level
project may be added only if it is a **companion to Apache Cassandra** (not Cassandra core), is
maintained by the Cassandra community, and benefits materially from co-location with the
existing projects. **Adding a new top-level project requires a lazy-consensus discussion on
[dev@cassandra.apache.org](mailto:dev@cassandra.apache.org)** (or a follow-up CEP for anything
large). Cassandra core does **not** live here.

## Building

Build each project from its own directory:

```bash
# Analytics (default profile: Spark 3 / Scala 2.12 / JDK 11; override via env vars)
cd analytics && ./gradlew build

# Sidecar (Java 11 server; requires dtest jars — see sidecar docs)
cd sidecar && ./gradlew build
```

The analytics build profile is selected with the `SPARK_VERSION`, `SCALA_VERSION`, and
`JDK_VERSION` environment variables (e.g. `SPARK_VERSION=4 SCALA_VERSION=2.13 JDK_VERSION=17`).
A thin top-level [`Makefile`](Makefile) provides convenience targets (`make build-analytics`,
`make build-sidecar`, `make build-all`, `make release VERSION=x.y.z`) that delegate into each
subdirectory.

## Versioning & releases

All modules share a single, lock-step version line (both projects are currently
`0.5-SNAPSHOT`). A release stamps the same version into both `analytics/gradle.properties` and
`sidecar/gradle.properties`; a release that only changes one project still bumps the other
(noted in release notes). **Published artifact names and coordinates are unchanged** by the
merge — analytics artifacts keep their `..._sparkN_scala` suffixes and sidecar keeps its
`sidecar-*` names.

## Continuous integration

CI runs per-project and only exercises what changed:

- **GitHub Actions** — [`analytics-ci.yml`](.github/workflows/analytics-ci.yml) and
  [`sidecar-ci.yml`](.github/workflows/sidecar-ci.yml). Each always runs but gates its heavy
  jobs behind a change-detection step; an always-running aggregator ("Analytics CI Gate" /
  "Sidecar CI Gate") is the single required status check per project, so a single-project PR
  merges cleanly while real failures still block.
- **CircleCI** — dynamic config ([`.circleci/config.yml`](.circleci/config.yml) →
  [`continue-config.yml`](.circleci/continue-config.yml)) uses path filtering to run only the
  changed project's workflow. Requires CircleCI "dynamic config" to be enabled (INFRA).

## Per-project references

- Analytics: [README_ANALYTICS.md](README_ANALYTICS.md) ·
  [changes](analytics/CHANGES.txt) · [news](analytics/NEWS.txt) · [notice](analytics/NOTICE.txt) ·
  [dev guide](analytics/DEV-README.md)
- Sidecar: [README_SIDECAR.md](README_SIDECAR.md) ·
  [changes](sidecar/CHANGES.txt) · [news](sidecar/NEWS.txt) · [notice](sidecar/NOTICE.txt) ·
  [contributing](sidecar/CONTRIBUTING.md) · [testing](sidecar/TESTING.md) ·
  [OpenAPI](sidecar/OPENAPI.md)

## Contributing

Contributions are welcome. Join `#cassandra-dev` in
[ASF Slack](https://infra.apache.org/slack.html). Issues are tracked in separate Jira projects —
[CASSANALYTICS](https://issues.apache.org/jira/projects/CASSANALYTICS/issues) for Analytics and
[CASSSIDECAR](https://issues.apache.org/jira/projects/CASSSIDECAR/issues) for Sidecar.

## License

Apache License 2.0 — see [LICENSE.txt](LICENSE.txt).
