# `repofetch`

[![Crates.io](https://img.shields.io/crates/v/repofetch?logo=rust)](https://crates.io/crates/repofetch)
![Crates.io](https://img.shields.io/crates/d/repofetch?logo=rust)
![CI](https://github.com/spenserblack/repofetch/workflows/CI/badge.svg)

Fetch details about your remote repository

## Screenshot

*__NOTE__ This screenshot is only an example, and does not accurately represent output. This 
screenshot lacks ASCII art, some new stats, and some changes to how some stats are formatted.*

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

- `emojis`

  These configuration settings lets you control which emojis display for each stat
  
  **Example**
  ```yml
  created: 🎉
  ```
  
- `ascii`

  This configuration setting lets you change the ASCII art that is displayed
  
- `labels`

  This configuration setting lets you rename the labels used for certain stats
  
  **Example**
  ```yml
  good first issue: easy
  ```


- `GITHUB TOKEN`

  If you run `repofetch` multiple times in a short span of time, you may max out the
  amount of queries you can make to GitHub's search API. This will result in some stats
  being `???`. If you set the `GITHUB TOKEN` config option to a [personal access token][PAC],
  `repofetch` can use this value to query GitHub's search API more often.

[PAC]: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
[crates.io]: https://crates.io/crates/repofetch
