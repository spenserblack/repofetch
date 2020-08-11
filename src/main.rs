use big_bytes::BigByte;
use cli::app;
use github_stats::Repo;

fn main() {
    let matches = app().get_matches();

    let repo = matches.value_of(cli::REPO_OPTION_NAME).unwrap();
    let repo_stats = {
        let mut repo = repo.split('/');
        let owner = repo.next().expect("No repo owner");
        let repo = repo.next().expect("No repo name");
        Repo::new(owner, repo).expect("Could not fetch remote repo data")
    };
    println!("{}:", repo);
    println!("{emoji}URL: {stat}", stat=repo_stats.clone_url(), emoji="");
    println!("{emoji}stargazers: {stat}", stat=repo_stats.stargazers_count(), emoji=emojis::STAR);
    println!("{emoji}subscribers: {stat}", stat=repo_stats.subscribers_count(), emoji=emojis::WATCHER);
    println!("{emoji}forks: {stat}", stat=repo_stats.forks_count(), emoji="");
    println!("{emoji}created: {stat}", stat=repo_stats.created_at(), emoji=emojis::CREATED);
    println!("{emoji}updated: {stat}", stat=repo_stats.updated_at(), emoji="");
    println!("{emoji}size: {stat}", emoji="", stat={
        let size = repo_stats.size();
        let size = size * 1_000; // convert from KB to just B
        size.big_byte(2)
    });
    println!("{emoji}fork: {stat}", stat=repo_stats.fork(), emoji="");
}

mod cli;
mod emojis;
