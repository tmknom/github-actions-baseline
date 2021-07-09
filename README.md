# GitHub Actions Baseline

A collection of useful GitHub Actions for all kinds of projects

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
curl -fsSL https://raw.githubusercontent.com/tmknom/github-actions-template/main/install.sh | bash -s /path/to/repository
```

After running, fetch some files automatically.

- Create the workflow files into the `.github/workflows` directory
- Create the tool configuration files used by workflow into the specified target directory

If you create a new repository, you can create it from this template repository.
For more information, see [Creating
a repository from a template](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/creating-a-repository-from-a-template).

## License

Apache 2 Licensed. See LICENSE for full details.
