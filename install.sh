#!/bin/bash
#
# Install Script
set -e -o pipefail

# Check prerequisites
BASE_URL="https://raw.githubusercontent.com/tmknom/github-actions-baseline/main"

USAGE="Usage: curl -fsSL ${BASE_URL}/install.sh | bash -s /path/to/repository"
usage() {
  echo "${USAGE}"
}

TARGET_DIR="${1}"
if [ ! "${TARGET_DIR}" ]; then
  usage
  exit 2
fi

# Define install files
WORKFLOW_FILES=(
  test-commit.yml
  test-dockerfile.yml
  test-json.yml
  test-makefile.yml
  test-markdown.yml
  test-secret.yml
  test-shell.yml
  test-writing.yml
  test-yaml.yml
)

CONFIG_FILES=(
  .commitlintrc.yml
  .markdownlint.yml
  .prettierrc.yml
  .yamllint.yml
)

# Setup tmpdir
TMP_INSTALL_DIR=$(mktemp -d "${TMPDIR:-/tmp}"/github-actions-baseline-XXXXXX)
mkdir -p "${TMP_INSTALL_DIR}"/workflows
mkdir -p "${TMP_INSTALL_DIR}"/configs

# Fetch files
for file in "${WORKFLOW_FILES[@]}"; do
  curl -fsSL "${BASE_URL}"/.github/workflows/"${file}" -o "${TMP_INSTALL_DIR}"/workflows/"${file}"
done

for file in "${CONFIG_FILES[@]}"; do
  curl -fsSL "${BASE_URL}"/"${file}" -o "${TMP_INSTALL_DIR}"/configs/"${file}"
done

# Copy files
mkdir -p "${TARGET_DIR}"/.github/workflows
cp -r "${TMP_INSTALL_DIR}"/workflows/. "${TARGET_DIR}"/.github/workflows
cp -r "${TMP_INSTALL_DIR}"/configs/. "${TARGET_DIR}"

# Show fetched files
printf "\e[32mFetched workflow files at %s/.github/workflows/\n\e[m" "${TARGET_DIR}"
# shellcheck disable=SC2012
ls -At "${TARGET_DIR}"/.github/workflows | head -n "${#WORKFLOW_FILES[*]}" | sort

printf "\e[32m\nFetched config files at %s/\n\e[m" "${TARGET_DIR}"
# shellcheck disable=SC2012
ls -At "${TARGET_DIR}" | head -n "${#CONFIG_FILES[*]}" | sort
