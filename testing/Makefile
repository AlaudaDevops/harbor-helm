REPORT ?= pretty
GODOG_ARGS ?= --godog.concurrency=2 --godog.format=$(REPORT)
E2E_CONFIG ?= ./config.yaml
TEST_COMMAND ?= go test -timeout=1h -v -count 1 .
ARCH ?= amd64
BIN ?= ./bin

build:
	GOOS=linux GOARCH=$(ARCH) go test -c -o "$(BIN)/harbor.test" ./

generate:
	@bash hack/generate-values-snippet.sh

create-testing-ns:
	kubectl create ns bdd-testing || true

TAGS ?= @harbor-chart-deploy-network-http
test: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags=$(TAGS)

test-smoke: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags="@smoke && ~@e2e"

test-all: create-testing-ns
	$(TEST_COMMAND) $(GODOG_ARGS) --godog.tags="~@e2e"

test-e2e: create-testing-ns
	bash -x hack/run-e2e.sh $(E2E_CONFIG)

report:
	allure generate --clean
	allure open

help:
	go test -v . --godog.help

# Update the image tag in the specified file
# Usage:
# To update the image tag in TEST_IMAGE:
#   make update-e2e-image-tag TAG=<new-tag> [E2E_SCRIPT=<target-file>]
# Example:
#   make update-e2e-image-tag TAG=2.12.5-g30bbb6d
# This updates TEST_IMAGE=registry.alauda.cn:60070/devops/harbor-e2e-engine:<old-tag> to
# TEST_IMAGE=registry.alauda.cn:60070/devops/harbor-e2e-engine:2.12.5-g30bbb6d in testdata/script/run-harbor-e2e.sh
E2E_SCRIPT ?= testdata/script/run-harbor-e2e.sh
.PHONY: update-e2e-image-tag
update-e2e-image-tag:
	@if [ -z "$(TAG)" ]; then \
		echo "Error: TAG must be provided."; \
		echo "Usage: make update-e2e-image-tag TAG=<new-tag> [E2E_SCRIPT=<target-file>]"; \
		exit 1; \
	fi
	@if [ ! -f "$(E2E_SCRIPT)" ]; then \
		echo "Error: File $(E2E_SCRIPT) not found."; \
		exit 1; \
	fi
	@if ! grep -q "TEST_IMAGE=.*registry.alauda.cn:60070/devops/harbor-e2e-engine" "$(E2E_SCRIPT)"; then \
		echo "Error: TEST_IMAGE string not found in $(E2E_SCRIPT)."; \
		exit 1; \
	fi
	@# Use sed to replace the tag in TEST_IMAGE string, preserving ${TEST_IMAGE:-...} structure
	@sed -i "s|\(registry\.alauda\.cn:60070/devops/harbor-e2e-engine:\)[^\"}]*|\1${TAG}|g" "$(E2E_SCRIPT)"
	@echo "Updated TEST_IMAGE tag to $(TAG) in $(E2E_SCRIPT)"
	@# Display the updated line for verification
	@grep "TEST_IMAGE=" "$(E2E_SCRIPT)"
