use anyhow::Result;
use colored::Colorize;
use chrono_humanize::Humanize;
use github_stats::*;
use humansize::{FileSize, file_size_opts};
use futures::join;
use super::apply_authorization;
use super::configuration::RepofetchConfig;
use super::configuration::ascii;
use super::{stat_string, write_output};

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

    let mut stats = vec![
        format!("{}:", format!("{}/{}", owner, repo).bold()),
        stat_string("URL", emojis.url, repo_stats.clone_url()),
        stat_string("stargazers", emojis.star, repo_stats.stargazers_count()),
        stat_string("subscribers", emojis.subscriber, repo_stats.subscribers_count()),
        stat_string("forks", emojis.fork, repo_stats.forks_count()),
    ];

    let open_issues = match open_issues {
        Ok(open) => open.total_count().to_string(),
        _ => "???".into(),
    };
    let closed_issues = match closed_issues {
        Ok(closed) => closed.total_count().to_string(),
        _ => "???".into(),
    };
    stats.push(stat_string(
        "open/closed issues",
        emojis.issue,
        format!("{}/{}", open_issues, closed_issues)
    ));

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
    stats.push(stat_string(
        "open/merged/closed PRs",
        emojis.pull_request,
        format!("{}/{}/{}", open_prs, merged_prs, closed_prs),
    ));

    stats.push(stat_string("created", emojis.created, repo_stats.created_at().humanize()));
    stats.push(stat_string("updated", emojis.updated, repo_stats.updated_at().humanize()));

    stats.push(stat_string(
        "size",
        emojis.size,
        {
            let size = repo_stats.size();
            let size = size * 1_000; // convert from KB to just B
            size.file_size(file_size_opts::BINARY).unwrap_or("???".into())
        },
    ));
    stats.push(stat_string("original", emojis.original, !repo_stats.fork()));

    let help_wanted = help_wanted.ok().map(|results| results.total_count());
    match help_wanted {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, help_wanted_label),
            emojis.help_wanted,
            count,
        )),
        _ => {},
    }

    let good_first_issue = good_first_issue.ok().map(|results| results.total_count());
    match good_first_issue {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, good_first_issue_label),
            emojis.good_first_issue,
            count,
        )),
        _ => {},
    }

    let hacktoberfest = hacktoberfest.ok().map(|results| results.total_count());
    let hacktoberfest = match hacktoberfest {
        Some(0) => None,
        count => count,
    };

    match hacktoberfest {
        Some(count) => stats.push(stat_string(
            "available hacktoberfest issues",
            emojis.hacktoberfest,
            count,
        )),
        _ => {},
    }

    write_output(ascii::GITHUB, stats);

    Ok(())
}
