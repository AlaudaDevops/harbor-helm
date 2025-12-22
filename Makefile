# yq version requirement
YQ_VERSION := 4.44.6
YQ := $(shell command -v yq 2> /dev/null)

# Check if yq is installed and verify version
.PHONY: check-yq
check-yq:
	@if [ -z "$(YQ)" ]; then \
		echo "Error: yq is not installed. Please install yq version $(YQ_VERSION)."; \
		exit 1; \
	fi
	@if ! yq --version | grep -q $(YQ_VERSION); then \
		echo "Warning: yq version $(YQ_VERSION) is recommended. Installed version: $$(yq --version)."; \
	fi

# Update component image tag in values.yaml
# Usage:
# To update a specific image tag:
#   make update-component-image-tag KEY=<key> TAG=<new-tag>
# Example:
#   make update-component-image-tag KEY=core TAG=2.12.4-g1234abc
# This updates global.images.core.tag to 2.12.4-g1234abc in values.yaml
.PHONY: update-component-image-tag
update-component-image-tag:
	@if [ -z "$(KEY)" ] || [ -z "$(TAG)" ]; then \
		echo "Error: Both KEY and TAG must be provided."; \
		echo "Usage: make update-component-image-tag KEY=<image-name> TAG=<new-tag>"; \
		exit 1; \
	fi
	@$(MAKE) update-yaml-value FILE=values.yaml KEY=global.images.$(KEY).tag VALUE=$(TAG)

# Update value in yaml file
# Usage:
#   make update-yaml-value FILE=<file-path> KEY=<key> VALUE=<new-value>
# Example:
#   make update-yaml-value FILE=values.yaml KEY=global.images.core.tag VALUE=2.12.4-g1234abc
# This updates global.images.core.tag to 2.12.4-g1234abc in values.yaml
.PHONY: update-yaml-value
update-yaml-value: check-yq
	@if [ -z "$(FILE)" ] || [ -z "$(KEY)" ] || [ -z "$(VALUE)" ]; then \
		echo "Error: FILE, KEY, and VALUE must be provided."; \
		echo "Usage: make update-yaml-value FILE=<file-path> KEY=<key> VALUE=<new-value>"; \
		exit 1; \
	fi
	@if [ ! -f $(FILE) ]; then \
		echo "Error: $(FILE) not found in current directory."; \
		exit 1; \
	fi
	@yq eval -i '.$(KEY) = "$(VALUE)"' $(FILE)
	@echo "Updated $(KEY) to $(VALUE) in $(FILE)"

