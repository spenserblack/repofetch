use clap::{App, Arg, crate_name, crate_version, crate_description};
use colored::Colorize;
use dirs::config_dir;
use futures::join;
use github_stats::*;
use humansize::{FileSize, file_size_opts};

use configuration::RepofetchConfig;

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

    let help_wanted_label = config.labels.help_wanted;
    let good_first_issue_label = config.labels.good_first_issue;

    let repo = matches.value_of(REPO_OPTION_NAME).unwrap();
    let (owner, repo) = {
        let mut repo = repo.split('/');
        let owner = repo.next().expect("No repo owner");
        let repo = repo.next().expect("No repo name");
        (owner, repo)
    };
    let repo_stats = Repo::new(owner, repo, user_agent!());

    let github_token = &config.github_token;

    let open_issues = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open");
    let open_issues = Search::issues(&open_issues);
    let open_issues = apply_authorization(open_issues, github_token);

    let closed_issues = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("closed");
    let closed_issues = Search::issues(&closed_issues);
    let closed_issues = apply_authorization(closed_issues, github_token);

    let open_prs = Query::new()
        .repo(owner, repo)
        .is("pr")
        .is("open");
    let open_prs = Search::issues(&open_prs);
    let open_prs = apply_authorization(open_prs, github_token);

    let merged_prs = Query::new()
        .repo(owner, repo)
        .is("pr")
        .is("merged");
    let merged_prs = Search::issues(&merged_prs);
    let merged_prs = apply_authorization(merged_prs, github_token);

    let closed_prs = Query::new()
        .repo(owner, repo)
        .is("pr")
        .is("closed")
        .is("unmerged");
    let closed_prs = Search::issues(&closed_prs);
    let closed_prs = apply_authorization(closed_prs, github_token);

    let help_wanted = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open")
        .no("assignee")
        .label(&format!(r#""{}""#, help_wanted_label));
    let help_wanted = Search::issues(&help_wanted);
    let help_wanted = apply_authorization(help_wanted, github_token);

    let good_first_issue = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open")
        .no("assignee")
        .label(&format!(r#""{}""#, good_first_issue_label));
    let good_first_issue = Search::issues(&good_first_issue);
    let good_first_issue = apply_authorization(good_first_issue, github_token);

    let hacktoberfest = Query::new()
        .repo(owner, repo)
        .is("issue")
        .is("open")
        .no("assignee")
        .label("hacktoberfest");
    let hacktoberfest = Search::issues(&hacktoberfest);
    let hacktoberfest = apply_authorization(hacktoberfest, github_token);

    let (
        repo_stats,
        open_issues,
        closed_issues,
        open_prs,
        merged_prs,
        closed_prs,
        help_wanted,
        good_first_issue,
        hacktoberfest,
    ) = join!(
        repo_stats,
        open_issues.search(user_agent!()),
        closed_issues.search(user_agent!()),
        open_prs.search(user_agent!()),
        merged_prs.search(user_agent!()),
        closed_prs.search(user_agent!()),
        help_wanted.search(user_agent!()),
        good_first_issue.search(user_agent!()),
        hacktoberfest.search(user_agent!()),
    );
    let repo_stats = repo_stats.expect("Could not fetch remote repo data");

    let emojis = config.emojis;
    println!("{}:", format!("{}/{}", owner, repo).bold());
    println_stat!("URL", repo_stats.clone_url(), emojis.url);
    println_stat!("stargazers", repo_stats.stargazers_count(), emojis.star);
    println_stat!("subscribers", repo_stats.subscribers_count(), emojis.subscriber);
    println_stat!("forks", repo_stats.forks_count(), emojis.fork);

    let open_issues = match open_issues {
        Ok(open) => open.total_count().to_string(),
        _ => "???".into(),
    };
    let closed_issues = match closed_issues {
        Ok(closed) => closed.total_count().to_string(),
        _ => "???".into(),
    };
    println_stat!("open/closed issues", format!("{}/{}", open_issues, closed_issues), emojis.issue);

    let open_prs = match open_prs {
        Ok(open) => open.total_count().to_string(),
        _ => "???".into(),
    };
    let merged_prs = match merged_prs {
        Ok(merged) => merged.total_count().to_string(),
        _ => "???".into(),
    };
    let closed_prs = match closed_prs {
        Ok(closed) => closed.total_count().to_string(),
        _ => "???".into(),
    };
    println_stat!(
        "open/merged/closed PRs",
        format!("{}/{}/{}", open_prs, merged_prs, closed_prs),
        emojis.pull_request,
    );


    println_stat!("created", repo_stats.created_at(), emojis.created);
    println_stat!("updated", repo_stats.updated_at(), emojis.updated);
    println_stat!("size", {
        let size = repo_stats.size();
        let size = size * 1_000; // convert from KB to just B
        size.file_size(file_size_opts::BINARY).unwrap_or("???".into())
    }, emojis.size);
    println_stat!("original", !repo_stats.fork(), emojis.original);

    let help_wanted = help_wanted.ok().map(|results| results.total_count());
    match help_wanted {
        Some(count) => println_stat!(
            format!(r#"available "{}" issues"#, help_wanted_label),
            count,
            emojis.help_wanted,
        ),
        _ => {},
    }

    let good_first_issue = good_first_issue.ok().map(|results| results.total_count());
    match good_first_issue {
        Some(count) => println_stat!(
            format!(r#"available "{}" issues"#, good_first_issue_label),
            count,
            emojis.good_first_issue,
        ),
        _ => {},
    }

    let hacktoberfest = hacktoberfest.ok().map(|results| results.total_count());
    let hacktoberfest = match hacktoberfest {
        Some(0) => None,
        count => count,
    };

    match hacktoberfest {
        Some(count) => println_stat!(
            "available hacktoberfest issues",
            count,
            emojis.hacktoberfest,
        ),
        _ => {},
    }
    Ok(())
}

fn apply_authorization(search: Search, auth: &Option<String>) -> Search {
    match auth {
        Some(token) => search.authorization(token),
        None => search,
    }
}

mod configuration;
