use anyhow::{Context, Result};
use clap::{App, Arg, crate_name, crate_version, crate_description};
use colored::Colorize;
use dirs::config_dir;
use github_stats::Search;
use itertools::Itertools;
use std::fmt::Display;

use configuration::RepofetchConfig;

macro_rules! user_agent {
    () => {
        concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION"))
    }
}

pub(crate) const REPO_OPTION_NAME: &str = "repository";
pub(crate) const CONFIG_OPTION_NAME: &str = "config";

#[tokio::main]
async fn main() -> Result<()> {

    let mut default_config = config_dir().unwrap();
    default_config.push("repofetch.yml");
    let default_config = default_config.as_os_str();

    let app = App::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .arg(
            Arg::with_name(REPO_OPTION_NAME)
                .index(1)
                .required(true)
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

    let repo = matches.value_of(REPO_OPTION_NAME).unwrap();
    let (owner, repo) = {
        let mut repo = repo.split('/');
        let owner = repo.next().context("No repo owner")?;
        let repo = repo.next().context("No repo name")?;
        (owner, repo)
    };

    github::main(owner, repo, config).await?;

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
            Both(ascii_line, stat) => println!("{:<45}{}", ascii_line, stat),
            Left(ascii_line) => println!("{}", ascii_line),
            Right(_stats) => unimplemented!("more stats than lines of ASCII"),
        }
    }
}

mod configuration;
mod github;
