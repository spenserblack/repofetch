use big_bytes::BigByte;
use cli::app;
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

#[tokio::main]
async fn main() {
    let matches = app().get_matches();
    let mut default_config = config_dir().unwrap();
    default_config.push("repofetch");
    let default_config = default_config;

    println!("Config: {:?}", RepofetchConfig::new(&default_config.display().to_string()));

    let repo = matches.value_of(cli::REPO_OPTION_NAME).unwrap();
    let (owner, repo) = {
        let mut repo = repo.split('/');
        let owner = repo.next().expect("No repo owner");
        let repo = repo.next().expect("No repo name");
        (owner, repo)
    };
    let repo_stats = Repo::new(owner, repo, user_agent!())
        .await
        .expect("Could not fetch remote repo data");
    println!("{}:", format!("{}/{}", owner, repo).bold());
    println_stat!("URL", repo_stats.clone_url(), emojis::URL);
    println_stat!("stargazers", repo_stats.stargazers_count(), emojis::STAR);
    println_stat!("subscribers", repo_stats.subscribers_count(), emojis::WATCHER);
    println_stat!("forks", repo_stats.forks_count(), emojis::FORK);
    println_stat!("created", repo_stats.created_at(), emojis::CREATED);
    println_stat!("updated", repo_stats.updated_at(), emojis::UPDATED);
    println_stat!("size", {
        let size = repo_stats.size();
        let size = size * 1_000; // convert from KB to just B
        size.big_byte(2)
    }, emojis::SIZE);
    println_stat!("original", !repo_stats.fork(), emojis::NOT_FORK);

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

mod cli;
mod configuration;
