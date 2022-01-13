# Contributing

## Testing Locally

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test hadolint https://github.com/looztra/asdf-hadolint.git "hadolint --help"
```

Tests are automatically run in GitHub Actions on push and PR.

## Linting Locally

```shell
task lint
task format
```
