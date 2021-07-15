# This option causes make to display a warning whenever an undefined variable is expanded.
MAKEFLAGS += --warn-undefined-variables

# Disable any builtin pattern rules, then speedup a bit.
MAKEFLAGS += --no-builtin-rules

# If this variable is not set, the program /bin/sh is used as the shell.
SHELL := /bin/bash

# The arguments passed to the shell are taken from the variable .SHELLFLAGS.
#
# The -e flag causes bash with qualifications to exit immediately if a command it executes fails.
# The -u flag causes bash to exit with an error message if a variable is accessed without being defined.
# The -o pipefail option causes bash to exit if any of the commands in a pipeline fail.
# The -c flag is in the default value of .SHELLFLAGS and we must preserve it.
# Because it is how make passes the script to be executed to bash.
.SHELLFLAGS := -eu -o pipefail -c

# Disable any builtin suffix rules, then speedup a bit.
.SUFFIXES:

# Sets the default goal to be used if no targets were specified on the command line.
.DEFAULT_GOAL := help

#
# Variables for the phony targets
#
DOCKERFILES ?= $(shell ls dockerfiles | sort)
BUILD_TARGETS ?= $(patsubst %,build-%,$(DOCKERFILES))
CLEAN_TARGETS ?= $(patsubst %,clean-%,$(DOCKERFILES))

#
# Variables for the current git attributes
#
BASE_BRANCH ?= main
CURRENT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
BASE_SHA ?= $(shell git merge-base remotes/origin/$(BASE_BRANCH) HEAD)
GIT_USER_NAME ?= $(shell git config user.name)
GIT_USER_EMAIL ?= $(shell git config user.email)

#
# Variables to be used by docker commands
#
DOCKER ?= $(shell which docker)
DOCKER_BUILD ?= $(DOCKER) build -t $(<F) $<
DOCKER_RUN ?= $(DOCKER) run -i --rm -v $(CURDIR):/work -w /work

#
# Variables to be used by test writing
#
MARKDOWN_FILES ?= $(shell find . -not -path './CHANGELOG.md' -name '*.md')

#
# Variables to be used by standard-version commands
#
STANDARD_VERSION ?= $(DOCKER_RUN) -v "$${TMPDIR}:/work/.git/hooks" \
                    -e GIT_COMMITTER_NAME="$(GIT_USER_NAME)" -e GIT_COMMITTER_EMAIL="$(GIT_USER_EMAIL)" \
                    -e GIT_AUTHOR_NAME="$(GIT_USER_NAME)" -e GIT_AUTHOR_EMAIL="$(GIT_USER_EMAIL)" standard-version

#
# Macros to be used by standard-version commands
#
define bump
	@release_type="$(1)" && \
	dry_run=$$($(STANDARD_VERSION) --dry-run --release-as $${release_type}) && \
	version=$$(echo "$${dry_run}" | grep tagging | cut -d " " -f 4) && \
	branch=release-$${version} && \
	set -x && \
	$(STANDARD_VERSION) --skip.commit --skip.tag --release-as $${release_type} && \
	$(MAKE) format-markdown && \
	git checkout -b $${branch} && \
	git add CHANGELOG.md && \
	git commit -m "chore(release): $${version}" && \
	git tag $${version} && \
	git push origin $${branch} $${version}
endef

#
# All
#
.PHONY: all
all: clean build test ## run clean, build and test

#
# Build docker images
#
.PHONY: build
build: $(BUILD_TARGETS) ## build all images

.PHONY: $(BUILD_TARGETS)
$(BUILD_TARGETS):
	IMAGE_NAME=$(patsubst build-%,%,$@) && $(DOCKER) build -t $${IMAGE_NAME} dockerfiles/$${IMAGE_NAME}

#
# Tests
#
.PHONY: test
test: test-dockerfile test-shell test-markdown test-yaml test-json test-github-actions test-secret test-writing ## test all

.PHONY: test-dockerfile
test-dockerfile: ## test dockerfile by hadolint and dockerfilelint
	find . -name Dockerfile | xargs $(DOCKER_RUN) hadolint/hadolint hadolint
	find . -name Dockerfile | xargs $(DOCKER_RUN) replicated/dockerfilelint
	$(DOCKER_RUN) bridgecrew/checkov --quiet -d .

.PHONY: test-shell
test-shell: ## test shell by shellcheck and shfmt
	find . -name '*.sh' | xargs $(DOCKER_RUN) koalaman/shellcheck:stable
	$(DOCKER_RUN) mvdan/shfmt -i 2 -ci -bn -d .

.PHONY: test-markdown
test-markdown: ## test markdown by markdownlint, remark and prettier
	$(DOCKER_RUN) markdownlint --dot **/*.md
	$(DOCKER_RUN) remark --silently-ignore **/*.md
	$(DOCKER_RUN) prettier --check --parser=markdown **/*.md

.PHONY: test-makefile
test-makefile: ## test makefile by checkmake
	find . -name Makefile | xargs -I {} $(DOCKER_RUN) checkmake {}

.PHONY: test-yaml
test-yaml: ## test yaml by yamllint and prettier
	$(DOCKER_RUN) yamllint --strict .
	$(DOCKER_RUN) prettier --check --parser=yaml **/*.y*ml

.PHONY: test-json
test-json: ## test json by jsonlint and prettier
	find . -name '*.json' | xargs -I {} $(DOCKER_RUN) jsonlint --quiet --compact {}
	$(DOCKER_RUN) prettier --check --parser=json **/*.json

.PHONY: test-github-actions
test-github-actions: ## test Github Actions by actionlint
	$(DOCKER_RUN) actionlint -color

.PHONY: test-secret
test-secret: ## test secret by secretlint
	$(DOCKER_RUN) secretlint/secretlint secretlint '**/*'
	$(DOCKER_RUN) zricethezav/gitleaks --path=/work -v --redact --commit-to=$(BASE_SHA) --branch=$(CURRENT_BRANCH)

.PHONY: test-writing
test-writing: ## test writing by write-good, proselint and alex
	$(DOCKER_RUN) write-good $(MARKDOWN_FILES)
	$(DOCKER_RUN) proselint $(MARKDOWN_FILES)
	$(DOCKER_RUN) alex $(MARKDOWN_FILES)

#
# Format code
#
.PHONY: format
format: format-shell format-markdown format-yaml format-json ## format all

.PHONY: format-shell
format-shell: ## format shell by shfmt
	$(DOCKER_RUN) mvdan/shfmt -i 2 -ci -bn -w .

.PHONY: format-markdown
format-markdown: ## format markdown by prettier
	$(DOCKER_RUN) prettier --write --parser=markdown **/*.md

.PHONY: format-yaml
format-yaml: ## format yaml by prettier
	$(DOCKER_RUN) prettier --write --parser=yaml **/*.y*ml

.PHONY: format-json
format-json: ## format json by prettier
	$(DOCKER_RUN) prettier --write --parser=json **/*.json

#
# Trigger test workflow in GitHub Actions
#
.PHONY: trigger
trigger: ## trigger all test workflows in GitHub Actions
	git branch release-test-all
	git push origin release-test-all
	git branch release-test-all -d
	git push origin release-test-all -d

#
# Bump version
#
.PHONY: bump-major
bump-major: ## bump major version and generate CHANGELOG.md
	$(call bump,major)

.PHONY: bump-minor
bump-minor: ## bump minor version and generate CHANGELOG.md
	$(call bump,minor)

.PHONY: bump-patch
bump-patch: ## bump patch version and generate CHANGELOG.md
	$(call bump,patch)

.PHONY: bump-first
bump-first: ## bump first version and generate CHANGELOG.md
	$(call bump,v0.1.0)

#
# Manage documents
#
.PHONY: docs
docs: ## manage documents
	$(DOCKER_RUN) --entrypoint=/app/gh-md-toc evkalinin/gh-md-toc:0.7.0 --insert --no-backup README.md
	$(MAKE) format-markdown

#
# Clean
#
.PHONY: clean
clean: $(CLEAN_TARGETS) ## docker rmi for all images

.PHONY: $(CLEAN_TARGETS)
$(CLEAN_TARGETS):
	IMAGE_NAME=$(patsubst clean-%,%,$@) && $(DOCKER) rmi $${IMAGE_NAME}

#
# Help
#
.PHONY: help-all
help-all: ## show help all
	@printf "\033[35mGeneral targets:\033[0m\n"
	@$(MAKE) help
	@printf "\n\033[35mBuild specified images:\033[0m\n"
	@$(MAKE) help-build
	@printf "\n\033[35mClean specified images:\033[0m\n"
	@$(MAKE) help-clean

.PHONY: help
help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: help-build
help-build:
	@echo $(BUILD_TARGETS) | sed 's/ /\n/g' | sort | awk '{s=$$1; sub(/-/," ",s); printf "\033[36m%-30s\033[0m %s image\n", $$1, s}'

.PHONY: help-clean
help-clean:
	@echo $(CLEAN_TARGETS) | sed 's/ /\n/g' | sort | awk '{s=$$1; sub(/-/," ",s); printf "\033[36m%-30s\033[0m %s image\n", $$1, s}'
