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
    println!("URL: {}", repo_stats.clone_url());
    println!("stargazers: {}{}", repo_stats.stargazers_count(), emojis::STAR);
    println!("subscribers: {}{}", repo_stats.subscribers_count(), emojis::WATCHER);
    println!("forks: {}", repo_stats.forks_count());
    println!("created: {}{}", repo_stats.created_at(), emojis::CREATED);
    println!("updated: {}", repo_stats.updated_at());
    println!("size: {}KB", repo_stats.size());
    println!("fork: {}", repo_stats.fork());
}

mod cli;
mod emojis;
