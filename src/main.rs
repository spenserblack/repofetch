use anyhow::{Context, Result};
use clap::{App, Arg, crate_name, crate_version, crate_description};
use colored::Colorize;
use dirs::config_dir;
use github_stats::Search;
use itertools::Itertools;
use std::fmt::Display;

use configuration::RepofetchConfig;
use configuration::ascii::MAX_WIDTH;

macro_rules! user_agent {
    () => {
        concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION"))
    }
}

pub(crate) const GITHUB_OPTION_NAME: &str = "github repository";
pub(crate) const CONFIG_OPTION_NAME: &str = "config";

enum RemoteHost {
    Github {
        owner: String,
        repository: String,
    },
}

impl RemoteHost {
    fn new() -> Option<RemoteHost> {
        None
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
        .arg(
            Arg::with_name(GITHUB_OPTION_NAME)
                .short("g")
                .long("github")
                .takes_value(true)
                .help("Your GitHub repository (`username/repo`)")
        )
        .arg(
            Arg::with_name(CONFIG_OPTION_NAME)
                .short("c")
                .long("config")
                .help("Path to config file to use")
                .default_value_os(default_config)
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
            let remote_host = RemoteHost::new()
                .context("Repository not found")?;
            match remote_host {
                Github{owner: o, repository: r} => {
                    github::main(&o, &r, config).await?;
                }
            }
        }
    }


    Ok(())
}

fn apply_authorization(search: Search, auth: &Option<String>) -> Search {
    match auth {
        Some(token) => search.authorization(token),
        None => search,
    }
}

fn stat_string<T>(title: &str, emoji: String, data: T)  -> String
    where T: Display
{
    format!("{emoji}{title}: {data}", emoji=emoji, title=title.bold(), data=data)
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
