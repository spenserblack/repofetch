use big_bytes::BigByte;
use clap::{App, Arg, crate_name, crate_version, crate_description};
use colored::Colorize;
use dirs::config_dir;
use github_stats::*;

use configuration::RepofetchConfig;
use configuration::emojis;

macro_rules! println_stat {
    ($name:expr, $stat:expr, $emoji:expr $(,)?) => {
        println!("{emoji}{name}: {stat}", name=$name.bold(), stat=$stat, emoji=$emoji)
    }
}

macro_rules! user_agent {
    () => {
        concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION"))
    }
}

pub(crate) const REPO_OPTION_NAME: &str = "repository";
pub(crate) const CONFIG_OPTION_NAME: &str = "config";

#[tokio::main]
async fn main() {

    let mut default_config = config_dir().unwrap();
    default_config.push("repofetch.yml");
    let default_config = default_config.as_os_str();

    let app = App::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .arg(
            Arg::with_name(REPO_OPTION_NAME)
                .index(1)
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
        Err(e) => {
            eprintln!("There was an issue with the config file: {}\nUsing default config.", e);
            RepofetchConfig::default()
        }
    };

    let repo = matches.value_of(REPO_OPTION_NAME).unwrap();
    let (owner, repo) = {
        let mut repo = repo.split('/');
        let owner = repo.next().expect("No repo owner");
        let repo = repo.next().expect("No repo name");
        (owner, repo)
    };
    let repo_stats = Repo::new(owner, repo, user_agent!())
        .await
        .expect("Could not fetch remote repo data");
    let emojis = config.emojis;
    println!("{}:", format!("{}/{}", owner, repo).bold());
    println_stat!("URL", repo_stats.clone_url(), emojis.url);
    println_stat!("stargazers", repo_stats.stargazers_count(), emojis.star);
    println_stat!("subscribers", repo_stats.subscribers_count(), emojis.subscriber);
    println_stat!("forks", repo_stats.forks_count(), emojis.fork);

    let open_issues = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open");
    let open_issues = Search::issues(&open_issues)
        .search(user_agent!())
        .await;
    let closed_issues = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("closed");
    let closed_issues = Search::issues(&closed_issues)
        .search(user_agent!())
        .await;
    let open_issues = match open_issues {
        Ok(open) => open.total_count().to_string(),
        _ => "???".into(),
    };
    let closed_issues = match closed_issues {
        Ok(closed) => closed.total_count().to_string(),
        _ => "???".into(),
    };
    println_stat!("open/closed issues", format!("{}/{}", open_issues, closed_issues), emojis.issue);

    let open_prs = Query::new()
        .repo(owner, repo)
        .is("pr")
        .is("open");
    let open_prs = Search::issues(&open_prs)
        .search(user_agent!())
        .await;
    let closed_prs = Query::new()
        .repo(owner, repo)
        .is("pr")
        .is("closed");
    let closed_prs = Search::issues(&closed_prs)
        .search(user_agent!())
        .await;
    let open_prs = match open_prs {
        Ok(open) => open.total_count().to_string(),
        _ => "???".into(),
    };
    let closed_prs = match closed_prs {
        Ok(closed) => closed.total_count().to_string(),
        _ => "???".into(),
    };
    println_stat!("open/closed PRs", format!("{}/{}", open_prs, closed_prs), emojis.pull_request);


    println_stat!("created", repo_stats.created_at(), emojis.created);
    println_stat!("updated", repo_stats.updated_at(), emojis.updated);
    println_stat!("size", {
        let size = repo_stats.size();
        let size = size * 1_000; // convert from KB to just B
        size.big_byte(2)
    }, emojis.size);
    println_stat!("original", !repo_stats.fork(), emojis.original);

    let hacktoberfest = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open")
        .no("assignee")
        .label("hacktoberfest");
    let hacktoberfest = Search::issues(&hacktoberfest)
        .search(user_agent!())
        .await;
    let hacktoberfest = hacktoberfest.ok().map(|results| results.total_count());
    let hacktoberfest = match hacktoberfest {
        Some(0) => None,
        count => count,
    };

    match hacktoberfest {
        Some(count) => println_stat!(
            "available hacktoberfest issues",
            count,
            emojis::HACKTOBERFEST,
        ),
        _ => {},
    }
}

mod configuration;
