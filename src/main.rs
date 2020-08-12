use big_bytes::BigByte;
use cli::app;
use colored::Colorize;
use github_stats::Repo;

macro_rules! println_stat {
    ($name:expr, $stat:expr, $emoji:expr) => {
        println!("{emoji}{name}: {stat}", name=$name.bold(), stat=$stat, emoji=$emoji);
    }
}

fn main() {
    let matches = app().get_matches();

    let repo = matches.value_of(cli::REPO_OPTION_NAME).unwrap();
    let repo_stats = {
        let mut repo = repo.split('/');
        let owner = repo.next().expect("No repo owner");
        let repo = repo.next().expect("No repo name");
        Repo::new(owner, repo).expect("Could not fetch remote repo data")
    };
    println!("{}:", repo.bold());
    println_stat!("URL", repo_stats.clone_url(), emojis::EMPTY);
    println_stat!("stargazers", repo_stats.stargazers_count(), emojis::STAR);
    println_stat!("subscribers", repo_stats.subscribers_count(), emojis::WATCHER);
    println_stat!("forks", repo_stats.forks_count(), emojis::EMPTY);
    println_stat!("created", repo_stats.created_at(), emojis::CREATED);
    println_stat!("updated", repo_stats.updated_at(), emojis::EMPTY);
    println_stat!("size", {
        let size = repo_stats.size();
        let size = size * 1_000; // convert from KB to just B
        size.big_byte(2)
    }, emojis::EMPTY);
    println_stat!("original", !repo_stats.fork(), emojis::NOT_FORK);
}

mod cli;
mod emojis;
