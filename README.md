# GitHub Actions Baseline

A collection of useful GitHub Actions for all kinds of projects

![test-dockerfile](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-dockerfile.yml/badge.svg)
![test-shell](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-shell.yml/badge.svg)
![test-markdown](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-markdown.yml/badge.svg)
![test-makefile](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-makefile.yml/badge.svg)
![test-yaml](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-yaml.yml/badge.svg)
![test-json](https://github.com/tmknom/github-actions-baseline/actions/workflows/test-json.yml/badge.svg)

## Description

GitHub Actions Baseline contains workflow definition that support for linting, format checking, secret scanning and English proofreading.
The workflow keeps clean for Dockerfile, Shell, Markdown, YAML and JSON.
Start from this baseline, then your code will be much more maintainable.

## Features

- **Linting**: Support for Dockerfile, Shell, Markdown, Makefile, YAML, JSON
- **Format Checking**: Support for Shell, Markdown, YAML, JSON
- **Secret Detection**: Scan hardcoded secrets like passwords, api keys and tokens
- **English Proofreading**: Suggest on how to improve your prose

## Getting Started

The easiest way to install GitHub Actions Baseline locally is through follow command.

```shell
curl -fsSL https://raw.githubusercontent.com/tmknom/github-actions-template/main/install.sh \
 | bash -s /path/to/repository
```

After running, fetch some files automatically.

- Create the workflow files into the `.github/workflows` directory
- Create the tool configuration files used by workflow into the specified target directory

If you create a new repository, you can create it from this template repository.
For more information, see [Creating
a repository from a template](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/creating-a-repository-from-a-template).

## Supported Workflows

### Test Dockerfile

- Lint by [hadolint](https://github.com/hadolint/hadolint), [dockerfilelint](https://github.com/replicatedhq/dockerfilelint) and [checkov](https://github.com/bridgecrewio/checkov)

### Test Shell

- Lint by [shellcheck](https://github.com/koalaman/shellcheck)
- Check formatting by [shfmt](https://github.com/mvdan/sh)

### Test Markdown

- Lint by [markdownlint](https://github.com/DavidAnson/markdownlint) and [remark](https://github.com/remarkjs/remark)
- Check formatting by [prettier](https://github.com/prettier/prettier)

### Test YAML

- Lint by [yamllint](https://github.com/adrienverge/yamllint)
- Check formatting by [prettier](https://github.com/prettier/prettier)

### Test JSON

- Lint by [jsonlint](https://github.com/zaach/jsonlint)
- Check formatting by [prettier](https://github.com/prettier/prettier)

### Test Secret

- Detect secret by [secretlint](https://github.com/secretlint/secretlint) and [gitleaks](https://github.com/zricethezav/gitleaks)

### Test Writing

- Proofread by [write-good](https://github.com/btford/write-good), [proselint](https://github.com/amperser/proselint) and [alex](https://github.com/get-alex/alex)

### Test Commit

- Check commit messages by [commitlint](https://github.com/conventional-changelog/commitlint)

## Developer Guide

### Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [Docker](https://docs.docker.com/get-docker/)

### Setup

<!-- lint disable ordered-list-marker-value -->

1. Clone repository

   ```shell
   git clone git@github.com:tmknom/github-actions-baseline.git
   ```

2. Build docker images that uses when test locally

   ```shell
   make build
   ```

<!-- lint enable ordered-list-marker-value -->

### Test

Run test locally using the docker image built during setup.

```shell
make test
```

### Release

Select the release type, and run one of the following command.

**Minor version up**:

```shell
make bump-minor
```

**Patch version up**:

```shell
make bump-patch
```

These commands perform the following process.

- Bump version
- Generate CHANGELOG.md
- Create new tag
- Push release branch

Then you can create a new Pull Request in GitHub, review updated CHANGELOG.md and merge.
After merged, the release workflow to update Releases page will run automatically.

## Changelog

See [CHANGELOG.md](/CHANGELOG.md) or [Releases page](https://github.com/tmknom/github-actions-baseline/releases).

## Author

- [@tmknom](https://github.com/tmknom/)

## License

Apache 2 Licensed. See LICENSE for full details.
