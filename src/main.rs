use anyhow::{Context, Result};
use clap::{crate_description, crate_name, crate_version, App, AppSettings, Arg};
use colored::Colorize;
use dirs::config_dir;
use git2::Repository;
use itertools::Itertools;
use lazy_static::lazy_static;
use regex::Regex;
use std::fmt::Display;

use configuration::ascii::MAX_WIDTH;
use configuration::RepofetchConfig;

lazy_static! {
    static ref GITHUB_RE: Regex = Regex::new(r"(?:(?:git@github\.com:)|(?:https?://github\.com/))(?P<owner>[\w\.\-]+)/(?P<repository>[\w\.\-]+)\.git").unwrap();
}

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

        let captures = GITHUB_RE
            .captures(origin_url)
            .context("Non-GitHub remotes not yet supported")?;

        let remote_host = Github {
            owner: captures.name("owner").context("no owner")?.as_str().into(),
            repository: captures
                .name("repository")
                .context("no repository")?
                .as_str()
                .into(),
        };

        Ok(remote_host)
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let mut default_config = config_dir().unwrap();
    default_config.push("repofetch.yml");
    let default_config = default_config.as_os_str();

    let app = App::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .global_setting(AppSettings::DeriveDisplayOrder)
        .arg(
            Arg::new(LOCAL_REPO_NAME)
                .short('r')
                .long("repository")
                .help("Path to a local repository to detect the appropriate remote host")
                .default_value("."),
        )
        .arg(
            Arg::new(GITHUB_OPTION_NAME)
                .short('g')
                .long("github")
                .takes_value(true)
                .help("Your GitHub repository (`username/repo`)"),
        )
        .arg(
            Arg::new(CONFIG_OPTION_NAME)
                .short('c')
                .long("config")
                .help("Path to config file to use")
                .default_value_os(default_config),
        );
    let matches = app.get_matches();

    let config = RepofetchConfig::new(matches.value_of(CONFIG_OPTION_NAME).unwrap());

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

    match matches.value_of(GITHUB_OPTION_NAME) {
        Some(repo) => {
            let mut repo = repo.split('/');
            let owner = repo.next().context("No repo owner")?;
            let repo = repo.next().context("No repo name")?;
            github::main(owner, repo, config).await?;
        }
        None => {
            use RemoteHost::*;
            let remote_host = RemoteHost::new(matches.value_of(LOCAL_REPO_NAME).unwrap())
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

    mod regex {
        use super::GITHUB_RE;

        mod github {
            use super::GITHUB_RE;

            #[test]
            fn http() {
                const URL: &str = "http://github.com/o/r.git";

                let captures = GITHUB_RE.captures(URL).expect("no captures");

                assert_eq!(Some("o"), captures.name("owner").map(|c| c.as_str()));
                assert_eq!(Some("r"), captures.name("repository").map(|c| c.as_str()));
            }

            #[test]
            fn https() {
                const URL: &str = "https://github.com/o/r.git";

                let captures = GITHUB_RE.captures(URL).expect("no captures");

                assert_eq!(Some("o"), captures.name("owner").map(|c| c.as_str()));
                assert_eq!(Some("r"), captures.name("repository").map(|c| c.as_str()));
            }

            #[test]
            fn ssh() {
                const URL: &str = "git@github.com:o/r.git";

                let captures = GITHUB_RE.captures(URL).expect("no captures");

                assert_eq!(Some("o"), captures.name("owner").map(|c| c.as_str()));
                assert_eq!(Some("r"), captures.name("repository").map(|c| c.as_str()));
            }

            #[test]
            fn weird_url() {
                const URL: &str = "https://github.com/us3r-nam3/r3p0-with.special.git";

                let captures = GITHUB_RE.captures(URL).expect("no captures");

                assert_eq!(
                    Some("us3r-nam3"),
                    captures.name("owner").map(|c| c.as_str())
                );
                assert_eq!(
                    Some("r3p0-with.special"),
                    captures.name("repository").map(|c| c.as_str())
                );
            }
        }
    }
}
