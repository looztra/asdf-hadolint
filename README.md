<div align="center">

# asdf-hadolint [![Build](https://github.com/looztra/asdf-hadolint/actions/workflows/build.yml/badge.svg)](https://github.com/looztra/asdf-hadolint/actions/workflows/build.yml) [![Lint](https://github.com/looztra/asdf-hadolint/actions/workflows/lint.yml/badge.svg)](https://github.com/looztra/asdf-hadolint/actions/workflows/lint.yml)

[hadolint](https://github.com/hadolint/hadolint#readme) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

<details open="open">
<summary>Table of Contents</summary>

- [Build History](#build-history)
- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
  - [Tooling Requirements](#tooling-requirements)
    - [Task](#task)
- [License](#license)

</details>

# Build History

[![Build history](https://buildstats.info/github/chart/looztra/asdf-hadolint?branch=main)](https://github.com/looztra/asdf-hadolint/actions)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.

# Install

Plugin:

```shell
asdf plugin add hadolint https://github.com/looztra/asdf-hadolint.git
```

hadolint:

```shell
# Show all installable versions
asdf list-all hadolint

# Install specific version
asdf install hadolint latest

# Set a version globally (on your ~/.tool-versions file)
asdf global hadolint latest

# Now hadolint commands are available
hadolint --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/looztra/asdf-hadolint/graphs/contributors)!

## Tooling Requirements

### Task

[Task](https://taskfile.dev/#/) is a great shell commands bootstrap solution (like `Make` but in Yaml) permitting you to make the same calls locally (for development phases) and within the CI/CD pipeline.

You want to get familiar with it? Read [this](https://tsh.io/blog/taskfile-and-gnu-make-for-automation/).

You can install it that way:

```bash
asdf plugin add task
# Will install the Task version referenced in ./tool-versions
asdf install task $(asdf current task | tr -s ' ' | cut -d' ' -f2)
task --version
```

# License

Licensed under the [Apache License 2.0](LICENSE)
