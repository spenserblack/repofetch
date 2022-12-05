# Contributing

## Contributing to repofetch

### Initializing your repository

This will install dependencies and also set up git to run code quality checks
when you attempt to make a commit. If you are using a codespace, this should
run automatically.

```bash
bundle install
bundle exec overcommit --install
```

## Writing a 3rd-party plugin

3rd-party plugins are Ruby gems that users can install and activate in their
configuration files.

You can view an officially supported plugin, like `Repofetch::Github`, as an
example for writing a plugin.

The easiest way to set up a plugin is to inherit from `Repofetch::Plugin`, which
will provide several helper methods that repofetch relies on to construct the
output. A few methods need to be implemented to complete your plugin:

### Required Plugin Class Methods

#### Detecting if repofetch should use a plugin

When a user does *not* explicitly choose their plugin from the command-line,
repofetch must select the plugin by matching it against a directory. `matches_repo?`
is a class method that takes a [`Git::Base`][git-base] instance and returns `true`
if repofetch should use the plugin for that repository, and `false` if repofetch should
not use the plugin (e.g. a GitHub plugin would return `false` for a GitLab repository).

#### Constructing the Plugin Instance

When repofetch selects a plugin using `matches_repo?`, it will then try to create an
instance of that plugin by calling `from_git`. From git will receive the
[`Git::Base`][git-base] instance, an array of CLI args that the plugin can use, and
an instance of `Repofetch::Config`.

If the user explicitly chooses the plugin to use via `repofetch --plugin <plugin>`, then
repofetch will pick that plugin and call its `from_args` class method. `from_args` takes
an array of CLI args and an instance of `Repofetch::Config`.

### Required Plugin Instance Methods

The following requirements assume you are *not* manually implementing a plugin's
`to_s` method, and you are inheriting from `Repofetch::Plugin`.

- `ascii` should return a string for the ASCII art
- `header` should return the header text that will be above the `---` separator on the right side.
- `stats` should return an array of values that implement `to_s`. These will be
  the stats displayed to the right of the ASCII art. You can use`Repofetch::Stat` and
  `Repofetch::TimespanStat` to create a pretty stat.

The following are optional.

- `theme` can return an instance of `Repofetch::Theme` to use a different color scheme.

### Authoring ASCII Art

The ASCII art should be no more than 40 characters wide or 20 characters tall.
It can receive ANSI escape sequences for styling by using `%{<style>}`. For example,
using the default theme, `%{red}foo%{reset}` would print `foo` with red text. See the
source code of `Repofetch::Theme` for all available default styles.

### Registering a Plugin

A plugin must register itself so that repofetch can discover it. You can call either
the plugin class's `register` method, or `Repofetch.register_plugin`.

### Example Plugin

This is a simple example of a plugin.

```ruby
require 'repofetch'

class MyCoolPlugin < Repofetch::Plugin
  def initialize(detected_from_git, arg_count)
    @detected_from_git = detected_from_git
    @arg_count = arg_count
  end

  def self.from_git(git, args)
    new(true, args.length)
  end

  def self.from_args(args)
    new(false, args.length)
  end

  def ascii
    <<~ASCII
      ####################
      #   %{bold}Hello, World%{reset}   #
      ####################
    ASCII
  end

  def header
    # NOTE: theme is provided by the base Plugin class
    "stats from #{theme.format(:underline, 'my plugin')}"
  end

  def stats
    # if theme is not passed, the stat will not be styled
    [
      Repofetch::Stat.new('git repo detected', @detected_from_git, emoji: '📂', theme: theme),
      Repofetch::Stat.new('args passed', @arg_count, theme: theme)
    ]
  end
end

# When the user adds your plugin to their configuration file, this line will register the plugin
MyCoolPlugin.register
```

### Guidelines

- For ASCII art, try to avoid using explicit black and white colors for negative and positive space.
  This can harm compatibility between light and dark terminals. Instead, simply use whitespace for
  negative space, and uncolored text for positive space.

[git-base]: https://www.rubydoc.info/github/ruby-git/ruby-git/Git/Base
