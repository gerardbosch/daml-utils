Just a few scripts for DAML plattform.

* `generate-java-bindings` - Generates a Maven library with the DAML bindings. Run it with `--help` to see its usage.
* `generate-scala-bindings` - TODO: Not implemented yet.

# Usage
Example:

```shell script
./generate-java-bindings --install com.example.daml.javabindings
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
      -i --install       Install the generated library in Maven local repository (mvn install).
      -o --output=<dir>  The output directory for the bindings generation [default: daml.java].
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

**NOTE**: You first `cd` into your DAML project.

## Add submodule (add the dependency)

```shell script
git submodule add --depth=1 https://git.gft.com/daml/daml-utils
git config -f .gitmodules submodule.daml-utils.ignore dirty

# Symlink scripts at the project's root for convenience
ln -s daml-utils/generate-java-bindings

git add .gitmodules generate-java-bindings
git commit -m "Add daml-utils submodule"
```

## Update submodule (sync with remote)

In order to keep the utils submodule in sync with its remote counterpart, you
can run the following which will pull last canges (if any) and update
supermodule to point to the last submodule commit:

```shell script
git submodule update --init --remote --depth=1 -- daml-utils
git add daml-utils && git commit -m "Update daml-utils from its remote"
```

