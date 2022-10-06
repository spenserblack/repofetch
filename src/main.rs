use anyhow::{Context, Result};
use clap::{
    builder::NonEmptyStringValueParser, crate_description, crate_name, crate_version, value_parser,
    AppSettings, Arg, Command,
};
use colored::Colorize;
use dirs::config_dir;
use git2::Repository;
use itertools::Itertools;
use std::fmt::Display;
use std::path::PathBuf;

use configuration::ascii::MAX_WIDTH;
use configuration::RepofetchConfig;

pub(crate) const LOCAL_REPO_NAME: &str = "local repository";
pub(crate) const GITHUB_OPTION_NAME: &str = "github repository";
pub(crate) const CONFIG_OPTION_NAME: &str = "config";

enum RemoteHost {
    Github { owner: String, repository: String },
}

impl RemoteHost {
    fn new(path: &str) -> Result<RemoteHost> {
        use RemoteHost::*;

        let repository = Repository::discover(path).context("Couldn't discover repository")?;
        let origin = repository
            .find_remote("origin")
            .context("Couldn't get remote origin")?;
        let origin_url = origin
            .url()
            .context("Couldn't decode remote origin to UTF-8")?;

        let (owner, repository) =
            github::repo_from_remote(origin_url).context("Non-GitHub remotes not yet supported")?;

        let remote_host = Github { owner, repository };

        Ok(remote_host)
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let mut default_config = config_dir().unwrap();
    default_config.push("repofetch.yml");
    let default_config = default_config.as_os_str();

    let app = Command::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .global_setting(AppSettings::DeriveDisplayOrder)
        .arg(
            Arg::new(LOCAL_REPO_NAME)
                .short('r')
                .long("repository")
                .value_parser(NonEmptyStringValueParser::new())
                .help("Path to a local repository to detect the appropriate remote host")
                .default_value("."),
        )
        .arg(
            Arg::new(GITHUB_OPTION_NAME)
                .short('g')
                .long("github")
                .takes_value(true)
                .value_parser(NonEmptyStringValueParser::new())
                .help("Your GitHub repository (`username/repo`)"),
        )
        .arg(
            Arg::new(CONFIG_OPTION_NAME)
                .short('c')
                .long("config")
                .help("Path to config file to use")
                .value_parser(value_parser!(PathBuf))
                .default_value_os(default_config),
        );
    let matches = app.get_matches();

    let config = RepofetchConfig::new(matches.get_one::<PathBuf>(CONFIG_OPTION_NAME).unwrap());

    let config = match config {
        Ok(config) => config,
        Err(error) => {
            eprintln!(
                "{}{}\n{}",
                "There was an issue with the config file: ".yellow().bold(),
                error,
                "Using default config.".yellow(),
            );
            RepofetchConfig::default()
        }
    };

    match matches.get_one::<String>(GITHUB_OPTION_NAME) {
        Some(repo) => {
            let mut repo = repo.split('/');
            let owner = repo.next().context("No repo owner")?;
            let repo = repo.next().context("No repo name")?;
            github::main(owner, repo, config).await?;
        }
        None => {
            use RemoteHost::*;
            let remote_host = RemoteHost::new(matches.get_one::<String>(LOCAL_REPO_NAME).unwrap())
                .context("Repository not found")?;
            match remote_host {
                Github {
                    owner: o,
                    repository: r,
                } => {
                    github::main(&o, &r, config).await?;
                }
            }
        }
    }

    Ok(())
}

fn stat_string<T>(title: &str, emoji: String, data: T) -> String
where
    T: Display,
{
    format!(
        "{emoji}{title}: {data}",
        emoji = emoji,
        title = title.bold(),
        data = data
    )
}

fn write_output(ascii: &str, stats: Vec<String>) {
    use itertools::EitherOrBoth::{Both, Left, Right};

    for line in ascii.lines().zip_longest(stats.iter()) {
        match line {
            Both(ascii_line, stat) => println!(
                "{:<ascii_padding$}{}",
                ascii_line,
                stat,
                ascii_padding = MAX_WIDTH + 5,
            ),
            Left(ascii_line) => println!("{}", ascii_line),
            Right(_stats) => unimplemented!("more stats than lines of ASCII"),
        }
    }
}

mod configuration;
mod github;

#[cfg(test)]
mod tests {
    use super::*;

    mod github_tests {
        use super::github;

        macro_rules! passing_repo_from_remote {
            ($name:ident, $url:literal, $owner:literal, $repo:literal) => {
                #[test]
                fn $name() {
                    let (owner, repo) = github::repo_from_remote($url).unwrap();
                    assert_eq!(owner, $owner);
                    assert_eq!(repo, $repo);
                }
            };
        }

        passing_repo_from_remote!(http, "http://github.com/owner/repo.git", "owner", "repo");
        passing_repo_from_remote!(https, "https://github.com/owner/repo.git", "owner", "repo");
        passing_repo_from_remote!(ssh, "git@github.com:owner/repo.git", "owner", "repo");
        passing_repo_from_remote!(complex_url, "https://github.com/us3r-nam3/r3p0-with.special.git", "us3r-nam3", "r3p0-with.special");
    }
}
