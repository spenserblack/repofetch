# `repofetch`

[![Build Status](https://travis-ci.com/spenserblack/repofetch.svg?branch=master)](https://travis-ci.com/spenserblack/repofetch)

[![Crates.io](https://img.shields.io/crates/v/repofetch?logo=rust)](https://crates.io/crates/repofetch)
![Crates.io](https://img.shields.io/crates/d/repofetch?logo=rust)

Fetch details about your remote repository

## Screenshot

Made with `repofetch spenserblack/repofetch`.

*__NOTE__ This screenshot will likely be out-of-date while `repofetch`'s version < 1.0.0*

![screenshot](https://github.com/spenserblack/repofetch/blob/master/images/screenshot.png?raw=true)

## Installation

### Latest Release from [Crates.io][crates.io]

```bash
cargo install repofetch
```

### Latest Commit from [this repo](https://github.com/spenserblack/repofetch)

```bash
cargo install --git https://github.com/spenserblack/repofetch.git
```

## Configuration

The first time you execute `repofetch`, it will create a `repofetch.yml` file in your default
config folder. You can edit this file to change `repofetch`'s output.

You can find where `repofetch.yml` is saved by default by executing `repofetch --help` and viewing
the help for the `<config>` option.

### Config File Contents

```yml
---
emojis: # Here you can change which emojis are displayed
  url: 🌐
  star: ⭐
  subscriber: 👀
  fork: 🔱
  issue: ❗
  pull request: 🔀
  created: 🎉 # This tells repofetch you want to use 🎉 for the `created` stat instead of the default (🐣)
  updated: 📤
  size: 💽
  original: 🥄
  help wanted: 🙇
  good first issue: 🔰
  hacktoberfest: 🎃
  placeholder: "  " # This is currently unused, but exists for potential future usage
labels: # Here you can provide aliases for labels
  help wanted: help wanted
  good first issue: great first issue # This tells repofetch that you want to search `label:"great first issue"` for good first issues
```

[crates.io]: https://crates.io/crates/repofetch
