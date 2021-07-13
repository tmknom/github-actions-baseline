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
  .remarkrc.yml
  .prettierrc.yml
  .yamllint.yml
)

echo "Started GitHub Actions Baseline install"

# Setup directory
TMP_INSTALL_DIR=$(mktemp -d "${TMPDIR:-/tmp}"/github-actions-baseline-XXXXXX)
TARGET_WORKFLOWS_DIR="${TARGET_DIR}"/.github/workflows
mkdir -p "${TARGET_WORKFLOWS_DIR}"

# Fetch and move files
for file in "${WORKFLOW_FILES[@]}"; do
  curl -fsSL "${BASE_URL}"/.github/workflows/"${file}" -o "${TMP_INSTALL_DIR}"/"${file}"
  mv "${TMP_INSTALL_DIR}"/"${file}" "${TARGET_WORKFLOWS_DIR}"
  printf "Created \e[32m%-20s\e[m into %s\n" "${file}" "${TARGET_WORKFLOWS_DIR}"/
done

for file in "${CONFIG_FILES[@]}"; do
  curl -fsSL "${BASE_URL}"/"${file}" -o "${TMP_INSTALL_DIR}"/"${file}"
  mv "${TMP_INSTALL_DIR}"/"${file}" "${TARGET_DIR}"
  printf "Created \e[32m%-20s\e[m into %s\n" "${file}" "${TARGET_DIR}"/
done

echo "Finished GitHub Actions Baseline install"
