# `repofetch`

[![Gem Version](https://badge.fury.io/rb/repofetch.svg)](https://badge.fury.io/rb/repofetch)
[![GitHub contributors (via allcontributors.org)](https://img.shields.io/github/all-contributors/spenserblack/repofetch)](./CREDITS.md)
![CI](https://github.com/spenserblack/repofetch/workflows/CI/badge.svg)
[![CodeQL](https://github.com/spenserblack/repofetch/actions/workflows/codeql.yml/badge.svg)](https://github.com/spenserblack/repofetch/actions/workflows/codeql.yml)
[![codecov](https://codecov.io/gh/spenserblack/repofetch/branch/master/graph/badge.svg?token=3572AEWQAY)](https://codecov.io/gh/spenserblack/repofetch)

Fetch details about your remote repository.

## Usage

![basic demo](./demos/demo.gif)

![advanced plugin usage](./demos/github-plugin.gif)

## Description

repofetch is a CLI tool to fetch stats (think [neofetch] or
[onefetch]) that uses plugins for its implementation. The original version was focused on
repository stats, and any official plugin will be for repositories, hence the "repo" in
repofetch. With 3rd-party plugins, however, it can support other types of outputs, too.

## Installation

### Via RubyGems.org

```bash
gem install repofetch
```

### Installing Version `< 0.4.0`

Version 0.3.3 and lower was a different implementation written in Rust. While `>= 0.4.0` is unstable
and likely buggy, you may want to use a lower version.

#### Via [Crates.io](https://crates.io/crates/repofetch)

```bash
cargo install repofetch
```

#### Via NetBSD

Pre-compiled binaries are available from the [official repositories](https://pkgsrc.se/sysutils/repofetch)
To install this, simply run:

```bash
pkgin install repofetch
```

#### Via AUR

If you are using an Arch machine, you can install repofetch from the [Aur](https://aur.archlinux.org).

```
yay -S ruby-repofetch
```

Or, if you prefer to build it from source:

```
cd /usr/pkgsrc/sysutils/repofetch
make install
```

You need to have `rust` and `libgit2` installed in order to build the package.

## Configuration

A file called `.repofetch.yml` in your home directory will configure repofetch. The
first time you run `repofetch`, the default configuration will be written to this file.

Files called `.repofetch.env` and `repofetch.env` in your home directory will set
environment variables for repofetch, via the [dotenv gem][dotenv]. These environment
variables can be useful for plugins that require secrets. The purpose of these files
is to separate secrets from configuration, so that, for example, you could add
`.repofetch.yml` to a dotfiles repository without compromising an API token.

You can find the absolute paths to these files with the `--help` option.

### Examples

```yaml
# .repofetch.yml
plugins:
  - 'repofetch/github'
```

```dotenv
# .repofetch.env
# Assuming you have gh (the GitHub CLI) installed
GITHUB_TOKEN=$(gh auth token)
```

## Notes on Rust Implementation (Version `< 0.4.0`)

I switched from Rust to Ruby to rewrite this project to use and support
plugins. I won't develop new features for the Rust implementation, but I may
fix bugs, and I'll review pull requests. The Rust implementation is on the
`rust` branch.

[dotenv]: https://github.com/bkeepers/dotenv
[neofetch]: https://github.com/dylanaraps/neofetch
[onefetch]: https://github.com/o2sh/onefetch
