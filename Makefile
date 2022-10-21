ifneq (,)
.error This Makefile requires GNU Make.
endif

# Ensure additional Makefiles are present
MAKEFILES = Makefile.docker Makefile.lint
$(MAKEFILES): URL=https://raw.githubusercontent.com/devilbox/makefiles/master/$(@)
$(MAKEFILES):
	@if ! (curl --fail -sS -o $(@) $(URL) || wget -O $(@) $(URL)); then \
		echo "Error, curl or wget required."; \
		echo "Exiting."; \
		false; \
	fi
include $(MAKEFILES)

# Set default Target
.DEFAULT_GOAL := help


# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
# Own vars
TAG        = latest

# Makefile.docker overwrites
NAME       = jsonlint
VERSION    = latest
IMAGE      = cytopia/${NAME}
FLAVOUR    = latest
FILE       = Dockerfile.${FLAVOUR}
DIR        = Dockerfiles
ifeq ($(strip $(FLAVOUR)),latest)
	DOCKER_TAG = $(TAG)
else
	ifeq ($(strip $(TAG)),latest)
		DOCKER_TAG = $(FLAVOUR)
	else
		DOCKER_TAG = $(FLAVOUR)-$(TAG)
	endif
endif
ARCH       = linux/amd64
ifeq ($(strip $(ARCH)),linux/arm64)
	ifeq ($(strip $(FLAVOUR)),latest)
		FILE = Dockerfile.jessie-arm64
	endif
	ifeq ($(strip $(FLAVOUR)),jessie)
		FILE = Dockerfile.jessie-arm64
	endif
endif

# Makefile.lint overwrites
FL_IGNORES  = .git/,.github/,tests/,Dockerfiles/data/
SC_IGNORES  = .git/,.github/,tests/


# -------------------------------------------------------------------------------------------------
#  Default Target
# -------------------------------------------------------------------------------------------------
.PHONY: help
help:
	@echo "lint                                     Lint project files and repository"
	@echo
	@echo "build [ARCH=...] [TAG=...]               Build Docker image"
	@echo "rebuild [ARCH=...] [TAG=...]             Build Docker image without cache"
	@echo "push [ARCH=...] [TAG=...]                Push Docker image to Docker hub"
	@echo
	@echo "manifest-create [ARCHES=...] [TAG=...]   Create multi-arch manifest"
	@echo "manifest-push [TAG=...]                  Push multi-arch manifest"
	@echo
	@echo "test [ARCH=...]                          Test built Docker image"
	@echo


# -------------------------------------------------------------------------------------------------
#  Docker Targets
# -------------------------------------------------------------------------------------------------
.PHONY: build
build: ARGS=--build-arg VERSION=$(VERSION)
build: docker-arch-build

.PHONY: rebuild
build: ARGS=--build-arg VERSION=$(VERSION)
rebuild: docker-arch-rebuild

.PHONY: push
push: docker-arch-push


# -------------------------------------------------------------------------------------------------
#  Manifest Targets
# -------------------------------------------------------------------------------------------------
.PHONY: manifest-create
manifest-create: docker-manifest-create

.PHONY: manifest-push
manifest-push: docker-manifest-push


# -------------------------------------------------------------------------------------------------
#  Test Targets
# -------------------------------------------------------------------------------------------------
.PHONY: test
test: _test-version
test: _test-run

.PHONY: _test-version
_test-version:
	@echo "------------------------------------------------------------"
	@echo "- Testing correct version"
	@echo "------------------------------------------------------------"
	@if [ "$(VERSION)" = "latest" ]; then \
		echo "Fetching latest version from GitHub"; \
		LATEST="$$( \
			curl -L -sS  https://github.com/zaach/jsonlint/tags/ \
				| tac | tac \
				| grep -Eo "zaach/jsonlint/releases/tag/v[.0-9]+" \
				| head -1 \
				| sed 's/.*v//g' \
		)"; \
		echo "Testing for latest: $${LATEST}"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "^v?$${LATEST}$$"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	else \
		echo "Testing for version: $(VERSION)"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "^v?$(VERSION)$$"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	fi; \
	echo "Success"; \

.PHONY: _test-versionrun
_test-run:
	@echo "------------------------------------------------------------"
	@echo "- Testing playbook"
	@echo "------------------------------------------------------------"
	@if ! docker run --rm -v $(CURRENT_DIR)/tests:/data $(IMAGE) -t '  ' *.json ; then \
		echo "Failed"; \
		exit 1; \
	fi; \
	echo "Success";
