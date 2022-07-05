# Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps,
and credit will always be given.

## Areas of contribution

Contributions are welcome across the entire project:

- Code
- Documentation
- Testing
- Packaging/distribution

## Contributing workflow

### New Contributors

1. Search the [issues](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules.git/issues) to see if there is an existing issue. If not, open an issue (note the issue ID).

1. Fork the repository to your personal namespace (only need to do this once).

1. Clone the repo from your personal namespace.

   `git clone https://github.com/{username}/terraform-azurerm-vmseries-modules.git`
   Ensure that `{username}` is _your_ user name.

1. Add the source repository as an upsteam.

   `git remote add upstream https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules.git`

1. Create a branch which corresponds to the issue ID created in step 1.

   For example, if the issue ID is 101:
   `git checkout -b 101-updating-wildfire-templates`

1. Make the desired changes and commit to your local repository.

1. Run the `pre-commit` script. See the [tools](#tools) section for more information.
   *NOTE* If making changes that will update the Terraform docs, this will need to be run twice.

1. Push changes to _your_ repository

   `git push origin/101-updating-wildfire-templates`

1. Rebase with the upstream to resolve any potential conflicts.

   `git rebase upstream dev`

1. Open a Pull Request and link it to the issue (reference the issue, i.e. "fixes #233")

1. Once the PR has been merged, delete your local branch

   `git branch -D 101-updating-wildfire-templates`

### Existing Contributors

1. Search the [issues](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules.git/issues) to see if there is an existing issue. If not, open an issue (note the issue ID).
1. Update from the source repository.

   `git pull upstream dev`

1. Create a branch which corresponds to the issue ID created in step 1.

   For example, if the issue ID is 101:
   `git checkout -b 101-updating-wildfire-templates`

1. Make any changes, and ensure the commit messages are clear and consistent (reference the issue ID and type of change in all commit messages)

1. [Test](#testing) the changes (preferably add tests for any code changes)

1. Document the changes (update the README and any other relevant documents)

1. Run the `pre-commit` script. See the [tools](#tools) section for more information.
   *NOTE* If making changes that will update the Terraform docs, this will need to be run twice.

1. Push changes to _your_ repository

   `git push origin/101-updating-wildfire-templates`
1. Rebase with the upstream to resolve any potential conflicts.

   `git rebase upstream dev`

1. Open a Pull Request and link it to the issue (reference the issue, i.e. "fixes #233")

1. Once the PR has been merged, delete your local branch

   `git branch -D 101-updating-wildfire-templates`

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

The first time `pre-commit` is run, it is possible to show "FAILED" if any docs were updated. This is expected behavior. Simply run `pre-commit` again and it should pass. Once all pre-commit tests pass, make another commit to check in those changes and push.

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
