use super::configuration::RepofetchConfig;
use super::{stat_string, write_output};
use anyhow::Result;
use chrono_humanize::Humanize;
use colored::Colorize;
use futures::join;
use humansize::{file_size_opts, FileSize};
use octocrab::OctocrabBuilder;

pub(crate) async fn main(owner: &str, repo: &str, config: RepofetchConfig) -> Result<()> {
    let help_wanted_label = config.labels.help_wanted;
    let good_first_issue_label = config.labels.good_first_issue;
    let octocrab = {
        let mut builder = OctocrabBuilder::new();
        if let Some(token) = config.github_token {
            builder = builder.personal_token(token);
        }
        builder.build()?
    };

    let repo_stats = octocrab.repos(owner, repo);
    let repo_stats = repo_stats.get();

    let gh_repo = format!("{}/{}", owner, repo);

    let open_issues = format!("repo:{repo} is:issue is:open", repo=gh_repo);
    let open_issues = octocrab.search()
        .issues_and_pull_requests(&open_issues)
        .per_page(1)
        .send();

    let closed_issues = format!("repo:{repo} is:issue is:closed", repo=gh_repo);
    let closed_issues = octocrab.search()
        .issues_and_pull_requests(&closed_issues)
        .per_page(1)
        .send();

    let open_prs = format!("repo:{repo} is:pr is:open", repo=gh_repo);
    let open_prs = octocrab.search()
        .issues_and_pull_requests(&open_prs)
        .per_page(1)
        .send();

    let merged_prs = format!("repo:{repo} is:pr is:merged", repo=gh_repo);
    let merged_prs = octocrab.search()
        .issues_and_pull_requests(&merged_prs)
        .per_page(1)
        .send();

    let closed_prs = format!("repo:{repo} is:pr is:closed is:unmerged", repo=gh_repo);
    let closed_prs = octocrab.search()
        .issues_and_pull_requests(&closed_prs)
        .per_page(1)
        .send();

    let help_wanted = format!(
                r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
                repo=gh_repo,
                label=help_wanted_label,
            );
    let help_wanted = octocrab.search()
        .issues_and_pull_requests(&help_wanted)
        .send();

    let good_first_issue = format!(
                r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
                repo=gh_repo,
                label=good_first_issue_label,
            );
    let good_first_issue = octocrab.search()
        .issues_and_pull_requests(&good_first_issue)
        .send();

    let hacktoberfest = format!(
                r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
                repo=gh_repo,
                label="hacktoberfest",
            );
    let hacktoberfest = octocrab.search()
        .issues_and_pull_requests(&hacktoberfest)
        .send();

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
        open_issues,
        closed_issues,
        open_prs,
        merged_prs,
        closed_prs,
        help_wanted,
        good_first_issue,
        hacktoberfest,
    );
    let repo_stats = repo_stats?;

    let emojis = config.emojis;

    let mut stats = vec![
        format!("{}:", format!("{}/{}", owner, repo).bold()),
        stat_string("URL", emojis.url, repo_stats.clone_url.map(String::from).unwrap_or("???".into())),
        stat_string("stargazers", emojis.star, repo_stats.stargazers_count.unwrap_or_default()),
        stat_string("subscribers", emojis.subscriber, repo_stats.subscribers_count.unwrap_or_default()),
        stat_string("forks", emojis.fork, repo_stats.forks_count.unwrap_or_default()),
    ];

    let open_issues = match open_issues {
        Ok(open) => open.total_count.unwrap_or_default().to_string(),
        _ => "???".into(),
    };
    let closed_issues = match closed_issues {
        Ok(closed) => closed.total_count.unwrap_or_default().to_string(),
        _ => "???".into(),
    };
    stats.push(stat_string(
        "open/closed issues",
        emojis.issue,
        format!("{}/{}", open_issues, closed_issues),
    ));

    let open_prs = match open_prs {
        Ok(open) => open.total_count.unwrap_or_default().to_string(),
        _ => "???".into(),
    };
    let merged_prs = match merged_prs {
        Ok(merged) => merged.total_count.unwrap_or_default().to_string(),
        _ => "???".into(),
    };
    let closed_prs = match closed_prs {
        Ok(closed) => closed.total_count.unwrap_or_default().to_string(),
        _ => "???".into(),
    };
    stats.push(stat_string(
        "open/merged/closed PRs",
        emojis.pull_request,
        format!("{}/{}/{}", open_prs, merged_prs, closed_prs),
    ));

    stats.push(stat_string(
        "created",
        emojis.created,
        repo_stats.created_at.map(|d| d.humanize()).unwrap_or("???".into()),
    ));
    stats.push(stat_string(
        "updated",
        emojis.updated,
        repo_stats.updated_at.map(|d| d.humanize()).unwrap_or("???".into()),
    ));

    stats.push(stat_string("size", emojis.size, {
        let size = repo_stats.size.unwrap_or_default();
        let size = size * 1_000; // convert from KB to just B
        size.file_size(file_size_opts::BINARY)
            .unwrap_or("???".into())
    }));
    stats.push(stat_string("original", emojis.original, !repo_stats.fork.unwrap_or(false)));

    let help_wanted = help_wanted.ok().map(|results| results.total_count.unwrap_or_default());
    match help_wanted {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, help_wanted_label),
            emojis.help_wanted,
            count,
        )),
        _ => {}
    }

    let good_first_issue = good_first_issue.ok().map(|results| results.total_count.unwrap_or_default());
    match good_first_issue {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, good_first_issue_label),
            emojis.good_first_issue,
            count,
        )),
        _ => {}
    }

    let hacktoberfest = hacktoberfest.ok().map(|results| results.total_count.unwrap_or_default());
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
        _ => {}
    }

    write_output(&config.ascii.github, stats);

    Ok(())
}
