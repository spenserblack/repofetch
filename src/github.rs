use anyhow::Result;
use colored::Colorize;
use chrono_humanize::Humanize;
use github_stats::*;
use humansize::{FileSize, file_size_opts};
use futures::join;
use super::apply_authorization;
use super::configuration::RepofetchConfig;

pub(crate) async fn main(owner: &str, repo: &str, config: RepofetchConfig) -> Result<()> {
    let help_wanted_label = config.labels.help_wanted;
    let good_first_issue_label = config.labels.good_first_issue;

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

    println_stat!("created", repo_stats.created_at().humanize(), emojis.created);
    println_stat!("updated", repo_stats.updated_at().humanize(), emojis.updated);

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
