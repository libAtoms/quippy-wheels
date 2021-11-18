# quippy-wheels

Wheel builder for [quippy](https://github.com/libAtoms/QUIP)

This uses [multibuild](https://github.com/matthew-brett/multibuild) to build
wheels for Mac OS X and manylinux.  Builds are trigged on every commit, but
wheels are only deployed to GitHub and PyPI on tags: GitHub for all
tags (including pre-release, e.g. `v0.9.x-rc1`) and PyPI just for full
releases (e.g. `v0.9.x`).

## Making a release

There are 3 steps:
1. Update the linked version of `QUIP`
2. Trigger the wheel build
3. Release wheels to PyPI

### 1. Update linked version of `QUIP`

The [QUIP](https://github.com/libAtoms/QUIP) source distribution (and its
dependent submodules, such as [GAP](https://github.com/libAtoms/QUIP)) is
included as git submodule, so you just need to update it to point to the
relevant commit and then commit and push the result:

```bash
cd QUIP
git pull # for example, update to tip of `public` branch
cd ..
git add QUIP
git commit -m 'update QUIP version'
```

### 2. Triggering the wheel build

To trigger a build, just push the new commit to the `quippy-wheel` GitHub repo `main`
branch.  If it is on a different branch you will need to create a pull request
from that branch to trigger the build action.

```bash
git push
```

Untagged releases will build wheels but not store them anywhere, so can be used
as a test that everything is working. Tagged releases generated wheels as GitHub
releases in this repo. It's a good idea to try a pre-release using a suffix such
as `-rc1` for the first attempt. If the tag is of a commit that is in
a branch other than `main` and is not part of a PR, it may not trigger the
storage of the built wheels.

```bash
git tag v0.9.x-rc1 # substitute x with the minor release, e.g. v0.9.1-rc1
git push --tags
```

If all goes well, the `.whl` files will show up as assets within a new GitHub
release. The installation process can now be tested locally, e.g. for 
version 0.9.5-rc3 on Mac OS X with Python 3.9:

```bash
pip install https://github.com/libAtoms/quippy-wheels/releases/download/v0.9.5-rc3/quippy_ase-0.9.5rc3-cp39-cp39-macosx_10_10_x86_64.whl
```

If there are problems with the build, the `test_osx.sh` and `test_docker.sh`
scripts can be useful to debug locally -- the Linux builds use Docker
containers, while the OS X one runs directly on the machine.

### 3. Release wheels to PyPI

Once everything works correctly, make a full release (i.e. create a tag named
just `v0.9.x` without the `-rc1` suffix). This will trigger the upload of wheels
to PyPI.

```bash
git tag v0.9.x # substitute x with the minor release, e.g. v0.9.1
git push --tags
```
