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
# Variables for the current git attributes
#
BASE_BRANCH ?= main
CURRENT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
BASE_SHA ?= $(shell git merge-base remotes/origin/$(BASE_BRANCH) HEAD)

#
# Variables to be used by docker commands
#
DOCKER ?= $(shell which docker)
DOCKER_BUILD ?= $(DOCKER) build -t $(<F) $<
DOCKER_RUN ?= $(DOCKER) run -i --rm -v $(CURDIR):/work -w /work
DOCKER_RMI ?= $(DOCKER) rmi

#
# All
#
.PHONY: all
all: clean build test ## run clean, build and test

#
# Build docker images
#
.PHONY: build
build: build-prettier build-markdownlint build-yamllint build-jsonlint build-write-good build-proselint build-alex ## build all docker images

.PHONY: build-prettier
build-prettier: dockerfiles/prettier ## docker build for prettier
	$(DOCKER_BUILD)

.PHONY: build-markdownlint
build-markdownlint: dockerfiles/markdownlint ## docker build for markdownlint
	$(DOCKER_BUILD)

.PHONY: build-yamllint
build-yamllint: dockerfiles/yamllint ## docker build for yamllint
	$(DOCKER_BUILD)

.PHONY: build-jsonlint
build-jsonlint: dockerfiles/jsonlint ## docker build for jsonlint
	$(DOCKER_BUILD)

.PHONY: build-write-good
build-write-good: dockerfiles/write-good ## docker build for write-good
	$(DOCKER_BUILD)

.PHONY: build-proselint
build-proselint: dockerfiles/proselint ## docker build for proselint
	$(DOCKER_BUILD)

.PHONY: build-alex
build-alex: dockerfiles/alex ## docker build for alex
	$(DOCKER_BUILD)

.PHONY: build-standard-version
build-standard-version: dockerfiles/standard-version ## docker build for standard-version
	$(DOCKER_BUILD)

#
# Tests
#
.PHONY: test
test: test-dockerfile test-shell test-markdown test-yaml test-json test-secret test-writing ## test all

.PHONY: test-dockerfile
test-dockerfile: ## test dockerfile by hadolint
	find . -name Dockerfile | xargs $(DOCKER_RUN) hadolint/hadolint hadolint

.PHONY: test-shell
test-shell: ## test shell by shellcheck and shfmt
	find . -name '*.sh' | xargs $(DOCKER_RUN) koalaman/shellcheck:stable
	$(DOCKER_RUN) mvdan/shfmt -i 2 -ci -bn -d .

.PHONY: test-markdown
test-markdown: ## test markdown by markdownlint and prettier
	$(DOCKER_RUN) markdownlint --dot **/*.md
	$(DOCKER_RUN) prettier --check --parser=markdown **/*.md

.PHONY: test-yaml
test-yaml: ## test yaml by yamllint and prettier
	$(DOCKER_RUN) yamllint --strict .
	$(DOCKER_RUN) prettier --check --parser=yaml **/*.y*ml

.PHONY: test-json
test-json: ## test json by jsonlint and prettier
	find . -name '*.json' | xargs -I {} $(DOCKER_RUN) jsonlint --quiet --compact {}
	$(DOCKER_RUN) prettier --check --parser=json **/*.json

.PHONY: test-secret
test-secret: ## test secret by secretlint
	$(DOCKER_RUN) secretlint/secretlint secretlint '**/*'
	$(DOCKER_RUN) zricethezav/gitleaks --path=/work -v --redact --commit-to=$(BASE_SHA) --branch=$(CURRENT_BRANCH)

.PHONY: test-writing
test-writing: ## test writing by write-good, proselint and alex
	find . -name '*.md' | xargs $(DOCKER_RUN) write-good
	find . -name '*.md' | xargs $(DOCKER_RUN) proselint
	$(DOCKER_RUN) alex '**/*.md'

#
# Clean
#
.PHONY: clean
clean: ## docker rmi for all images
	$(DOCKER_RMI) prettier
	$(DOCKER_RMI) markdownlint
	$(DOCKER_RMI) yamllint
	$(DOCKER_RMI) jsonlint
	$(DOCKER_RMI) write-good
	$(DOCKER_RMI) proselint
	$(DOCKER_RMI) alex

# Self-Documented Makefile
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
