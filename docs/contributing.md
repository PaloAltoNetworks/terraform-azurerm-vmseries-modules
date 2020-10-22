# Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps,
and credit will always be given.

## Coding Standards

Please follow the [Terraform conventions](terraform-conventions.md) for the project.

## Publish a new release (for maintainers)

### Test the release process

Testing the workflow requires node, npm, and semantic-release to be installed locally:

```
$ npm install -g semantic-release@^17.1.1 @semantic-release/git@^9.0.0 @semantic-release/exec@^5.0.0 conventional-changelog-conventionalcommits@^4.4.0
```

Run `semantic-release` on develop:

```
semantic-release --dry-run --no-ci --branches=develop
```

Verify in the output that the next version is set correctly, and the release notes are generated correctly.

### Merge develop to master and push

```
git checkout master
git merge develop
git push origin master
```

At this point, GitHub Actions builds and tags the release.

### Merge master to develop and push

Now, sync develop to master to add any commits made by the release bot.

```
git fetch --all --tags
git pull origin master
git checkout develop
git merge master
git push origin develop
```
