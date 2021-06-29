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
# Variables to be used by docker commands
#
DOCKER ?= $(shell which docker)
DOCKER_BUILD ?= $(DOCKER) build -t $(<F) $<
DOCKER_RUN ?= $(DOCKER) run -i --rm -v $(CURDIR):/work -w /work

#
# Build docker images
#
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

#
# Tests
#
.PHONY: test-shell
test-shell: ## test shell by shellcheck and shfmt
	find . -name *.sh | xargs $(DOCKER_RUN) koalaman/shellcheck:stable
	$(DOCKER_RUN) mvdan/shfmt -i 2 -ci -bn -d .

.PHONY: test-markdown
test-markdown: ## test markdown by markdownlint and prettier
	$(DOCKER_RUN) markdownlint --dot **/*.md
	$(DOCKER_RUN) prettier --check --parser=markdown **/*.md

.PHONY: test-yaml
test-yaml: ## test yaml by yamllint and prettier
	$(DOCKER_RUN) yamllint --strict .
	$(DOCKER_RUN) prettier --check --parser=yaml **/*.y*ml

# Self-Documented Makefile
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
