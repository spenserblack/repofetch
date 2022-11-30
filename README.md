# `repofetch`

[![GitHub contributors (via allcontributors.org)](https://img.shields.io/github/all-contributors/spenserblack/repofetch)](./CREDITS.md)
![CI](https://github.com/spenserblack/repofetch/workflows/CI/badge.svg)

Fetch details about your remote repository.

## Description

repofetch is a plugin-based CLI tool to fetch details (think [neofetch] or
[onefetch]). The original version was focused on repository stats, and any official
plugin will be for repositories, hence the "repo" in repofetch. With 3rd-party plugins,
however, it can support other types of outputs, too.

## Configuration

A file called `.repofetch.yml` in your home directory will configure repofetch. The
first time you run `repofetch`, the default configuration will be written to this file.

Files called `.repofetch.env` and `repofetch.env` in your home directory will set
environment variables for repofetch, via the [dotenv gem][dotenv]. These environment
variables can be useful for plugins that require secrets. The purpose of these files
is to separate secrets from configuration, so that, for example, you could add
`.repofetch.yml` to a dotfiles repository without compromising an API token.

You can find the absolute paths to these files with the `--help` option.

[dotenv]: https://github.com/bkeepers/dotenv
[neofetch]: https://github.com/dylanaraps/neofetch
[onefetch]: https://github.com/o2sh/onefetch
