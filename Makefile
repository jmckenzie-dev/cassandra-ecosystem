# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Thin top-level orchestration for the cassandra-ecosystem repo.
#
# The projects are independent Gradle builds under analytics/ and sidecar/, each
# with its own gradle wrapper. These targets just delegate into the right subdir —
# there is intentionally no aggregate Gradle build (see README.md / CEP-63).
#
# Analytics profile defaults to Spark 3 / Scala 2.12 / JDK 11; override on the
# command line, e.g.:  make build-analytics SPARK_VERSION=4 SCALA_VERSION=2.13 JDK_VERSION=17

.PHONY: help build-all build-analytics build-sidecar test-all test-analytics test-sidecar \
        dist-all dist-analytics dist-sidecar clean set-version print-version

help:
	@echo "Targets:"
	@echo "  build-analytics / build-sidecar / build-all   - assemble+check each project"
	@echo "  test-analytics  / test-sidecar  / test-all    - run unit tests"
	@echo "  dist-analytics  / dist-sidecar  / dist-all     - build distribution artifacts"
	@echo "  set-version VERSION=x.y.z                      - stamp both projects to one version (lock-step)"
	@echo "  print-version                                  - show each project's current version"
	@echo "  clean                                          - clean both projects"

build-analytics:
	cd analytics && ./gradlew --no-daemon clean assemble check -x cassandra-analytics-integration-tests:test

build-sidecar:
	cd sidecar && ./gradlew --no-daemon build -x integrationTest

build-all: build-analytics build-sidecar

test-analytics:
	cd analytics && ./gradlew --no-daemon test

test-sidecar:
	cd sidecar && ./gradlew --no-daemon test

test-all: test-analytics test-sidecar

dist-analytics:
	cd analytics && ./gradlew --no-daemon distTar distZip

dist-sidecar:
	cd sidecar && ./gradlew --no-daemon distTar distZip

dist-all: dist-analytics dist-sidecar

clean:
	cd analytics && ./gradlew --no-daemon clean
	cd sidecar && ./gradlew --no-daemon clean

# Lock-step version: stamp the SAME version into both gradle.properties (CEP-63 §4).
# A release that changes only one project still bumps the other (note in release notes).
set-version:
	@test -n "$(VERSION)" || { echo "Usage: make set-version VERSION=x.y.z"; exit 1; }
	sed -i.bak "s/^version=.*/version=$(VERSION)/" analytics/gradle.properties sidecar/gradle.properties
	rm -f analytics/gradle.properties.bak sidecar/gradle.properties.bak
	@echo "Stamped both projects to $(VERSION):"
	@$(MAKE) --no-print-directory print-version

print-version:
	@printf "analytics: "; grep '^version=' analytics/gradle.properties
	@printf "sidecar:   "; grep '^version=' sidecar/gradle.properties
