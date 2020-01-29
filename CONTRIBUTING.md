# Contributing to the SSITH GFE

While this repository is hosted by Galois, we rely on code contributions from
Bluespec and SSITH TA-1 engineers. To facilitate concurrent work on new
features, bug fixes, and improvements across organization boundaries, we've
chosen to adopt a few specific version control practices, documented here.


## Branch management

We use a version of the [git flow](https://nvie.com/posts/a-successful-git-branching-model/)
branching management discipline popularized by GitHub and adopted by many open source projects.
It is intended to support these properties of the repo:

- The `master` branch only contains tagged release versions
- The `develop` branch is always a stable snapshot of current work, where all tests pass
- Changes are implemented on branches which originate from and target the develop branch
- Merge requests are used to review and order branch merges back into develop

When contributing code to the GFE, please use the following process:

- When implementing new features or fixes, branch from current `develop`
- When finished with a working branch:
    - rebase onto `develop`, or merge `develop` into the work branch
    - run all GFE tests, either in CI or locally 
    - when tests pass, open a merge request targeting `develop`
    - include other contributors in code review as appropriate
    - if the branch addresses issues in the issue tracker, link to them
- Merge your own branch when it's approved by a Maintainer
  and you believe it has been adequately reviewed

We use GitLab's permissions model to help enforce this workflow.
Both `master` and `develop` branches require Maintainer-level permissions to push or merge.
Galois and Bluespec engineers have Maintainer permissions;
other contributors have Developer permissions.


## Releases

When releasing a new version of the GFE:

- Merge `develop` into `master`
- Tag with a semantic version number, such as `release-4.3`

