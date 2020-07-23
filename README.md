*The updated version of this repository is at https://github.com/gerardbosch/daml-utils*

Just a few scripts for the DAML plattform.

* `generate-java-bindings` - Generates a Maven library with the DAML bindings. Run it with `--help` to see its usage.
* `generate-scala-bindings` - TODO: Not implemented yet.

# Dependencies
* [DAML SDK](https://daml.com): Used by both building DAR and generating Java binding code.
* **Maven**: Generate and package/install/deploy an artifact from the generated
  binding sources.

# Usage
Example:

```shell script
./generate-java-bindings com.example.daml.javabinding --mvncommand install
```

Usage help:

```
❯ ./generate-java-bindings --help
Generate Java bindings for DAML.

It generates the package (mvn package) for the current directory DAML project.

  Usage:
    generate-java-bindings [options] <basepackage>

    basepackage is the base Java package for the generated code (e.g. com.example)

    Options:
      -c --mvncommand=<maven subcommand>  Possible values are `install` and `deploy` which directly binds to Maven [default: package].
      -o --output=<dir>                   The output directory for the bindings generation [default: daml.java].
```

# Installation

For convenience, you can add these scripts to your shell `PATH`. A convenient way
to do it is symlinking them to your `~/bin` like this:

```shell script
mkdir -p ~/bin && cd ~/bin && ln -s /path/to/daml-utils/generate-java-bindings
```

**Ensure** your `~/bin/` is is your PATH, your `.profile`/`.bashrc`/`.zshrc` or
equivalent should have something like this:

```shell script
# set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
```

This way you can run it from any DAML project directory.


# Alternate "install"

Another way to have these scripts in hand in your DAML projects is by adding this repository
as a Git submodule of your project. This way you bring this repository as a dependency of
your DAML project repository.

## Add submodule (add the dependency)

```shell script
cd to-your-daml-project  # Must be a Git project! (git init)
git submodule add --depth=1 https://github.com/gerardbosch/daml-utils.git
git config -f .gitmodules submodule.daml-utils.ignore dirty

# Symlink scripts at the project's root for convenience (care with Git for Windows)
ln -s daml-utils/generate-java-bindings

git add .gitmodules generate-java-bindings
git commit -m "Add daml-utils submodule"
```

**NOTE**: This installation option is portable (as travels with the repo) and
cool. But you *may* need to run `git submodule update --init --recursive`
after cloning the repo if submodule appears empty.

**NOTE**: When using Git for Windows, you *may* need to define `symlinks = true`
in the `[core]` section of your `~/.gitconfig` file. Otherwise UNIX symlinks are
broken.

## Update submodule (sync with remote)

In order to keep the utils submodule in sync with its remote counterpart, you
can run the following which will pull last canges (if any) and update
supermodule to point to the last submodule commit:

```shell script
git submodule update --init --remote --depth=1 -- daml-utils
git add daml-utils && git commit -m "Update daml-utils from its remote"
```

