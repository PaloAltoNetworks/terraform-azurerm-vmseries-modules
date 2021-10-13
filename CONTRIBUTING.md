# Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps,
and credit will always be given.

## Tools

Any serious changes, especially any changes of variables or providers, require the
`pre-commit` tool. Install the recommended versions:

- pre-commit v2.9.3 - [installation instruction](https://pre-commit.com/#installation) (a Python3 package)
- terraform-docs v0.15.0 - download the binary from [GitHub releases](https://github.com/terraform-docs/terraform-docs/releases)
- tflint v0.29.0 - download the binary from [GitHub releases](https://github.com/terraform-linters/tflint/releases)
- coreutils - required only on macOS, [install Homebrew](https://docs.brew.sh/Installation) and then run `brew install coreutils`

For more details, or for a dockerized pre-commit-terraform, see the [official guide](https://github.com/antonbabenko/pre-commit-terraform#how-to-install).

For these Contributors who prefer *not* to use the recommended git hooks, the command
to fully update the auto-generated README files and to run formatters/tests is:

```sh
pre-commit run -a
```

This command does not commit/add/push any changes to Git. It only changes local files.

## Coding Standards

Please follow the [Terraform conventions](https://github.com/PaloAltoNetworks/terraform-best-practices/blob/master/README.md).

## Publish a new release (for maintainers)

### Test the release process

Testing the workflow requires node, npm, and semantic-release to be installed locally:

```sh
npm install -g semantic-release@^17.1.1 @semantic-release/git@^9.0.0 @semantic-release/exec@^5.0.0 conventional-changelog-conventionalcommits@^4.4.0
```

Run `semantic-release` on develop:

```sh
semantic-release --dry-run --no-ci --branches=develop
```

Verify in the output that the next version is set correctly, and the release notes are generated correctly.

### Merge develop to master and push

```sh
git checkout master
git merge develop
git push origin master
```

At this point, GitHub Actions builds and tags the release.

### Merge master to develop and push

Now, sync develop to master to add any commits made by the release bot.

```sh
git fetch --all --tags
git pull origin master
git checkout develop
git merge master
git push origin develop
```
