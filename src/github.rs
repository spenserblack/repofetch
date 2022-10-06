use super::configuration::RepofetchConfig;
use super::{stat_string, write_output};
use anyhow::{Context, Result};
use chrono_humanize::Humanize;
use colored::Colorize;
use futures::join;
use humansize::{file_size_opts, FileSize};
use lazy_static::lazy_static;
use octocrab::OctocrabBuilder;
use regex::Regex;

lazy_static! {
    static ref GITHUB_RE: Regex = Regex::new(r"(?:(?:git@github\.com:)|(?:https?://github\.com/))(?P<owner>[\w\.\-]+)/(?P<repository>[\w\.\-]+)\.git").unwrap();
}

/// Creates an `owner/repo` tuple from a GitHub URL.
pub(crate) fn repo_from_remote(remote: &str) -> Result<(String, String)> {
    let captures = GITHUB_RE.captures(remote).context("no GitHub match")?;
    Ok((
        captures.name("owner").unwrap().as_str().into(),
        captures.name("repository").unwrap().as_str().into(),
    ))
}

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

    let open_issues = format!("repo:{repo} is:issue is:open", repo = gh_repo);
    let open_issues = octocrab
        .search()
        .issues_and_pull_requests(&open_issues)
        .per_page(1)
        .send();

    let closed_issues = format!("repo:{repo} is:issue is:closed", repo = gh_repo);
    let closed_issues = octocrab
        .search()
        .issues_and_pull_requests(&closed_issues)
        .per_page(1)
        .send();

    let open_prs = format!("repo:{repo} is:pr is:open", repo = gh_repo);
    let open_prs = octocrab
        .search()
        .issues_and_pull_requests(&open_prs)
        .per_page(1)
        .send();

    let merged_prs = format!("repo:{repo} is:pr is:merged", repo = gh_repo);
    let merged_prs = octocrab
        .search()
        .issues_and_pull_requests(&merged_prs)
        .per_page(1)
        .send();

    let closed_prs = format!("repo:{repo} is:pr is:closed is:unmerged", repo = gh_repo);
    let closed_prs = octocrab
        .search()
        .issues_and_pull_requests(&closed_prs)
        .per_page(1)
        .send();

    let help_wanted = format!(
        r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
        repo = gh_repo,
        label = help_wanted_label,
    );
    let help_wanted = octocrab
        .search()
        .issues_and_pull_requests(&help_wanted)
        .send();

    let good_first_issue = format!(
        r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
        repo = gh_repo,
        label = good_first_issue_label,
    );
    let good_first_issue = octocrab
        .search()
        .issues_and_pull_requests(&good_first_issue)
        .send();

    let hacktoberfest = format!(
        r#"repo:{repo} is:issue is:open no:assignee label:"{label}""#,
        repo = gh_repo,
        label = "hacktoberfest",
    );
    let hacktoberfest = octocrab
        .search()
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
        stat_string(
            "URL",
            emojis.url,
            repo_stats
                .clone_url
                .map(String::from)
                .unwrap_or("???".into()),
        ),
        stat_string(
            "stargazers",
            emojis.star,
            repo_stats.stargazers_count.unwrap_or_default(),
        ),
        stat_string(
            "subscribers",
            emojis.subscriber,
            repo_stats.subscribers_count.unwrap_or_default(),
        ),
        stat_string(
            "forks",
            emojis.fork,
            repo_stats.forks_count.unwrap_or_default(),
        ),
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
        repo_stats
            .created_at
            .map(|d| d.humanize())
            .unwrap_or("???".into()),
    ));
    stats.push(stat_string(
        "updated",
        emojis.updated,
        repo_stats
            .updated_at
            .map(|d| d.humanize())
            .unwrap_or("???".into()),
    ));

    stats.push(stat_string("size", emojis.size, {
        let size = repo_stats.size.unwrap_or_default();
        let size = size * 1_000; // convert from KB to just B
        size.file_size(file_size_opts::BINARY)
            .unwrap_or("???".into())
    }));
    stats.push(stat_string(
        "original",
        emojis.original,
        !repo_stats.fork.unwrap_or(false),
    ));

    let help_wanted = help_wanted
        .ok()
        .map(|results| results.total_count.unwrap_or_default());
    match help_wanted {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, help_wanted_label),
            emojis.help_wanted,
            count,
        )),
        _ => {}
    }

    let good_first_issue = good_first_issue
        .ok()
        .map(|results| results.total_count.unwrap_or_default());
    match good_first_issue {
        Some(count) => stats.push(stat_string(
            &format!(r#"available "{}" issues"#, good_first_issue_label),
            emojis.good_first_issue,
            count,
        )),
        _ => {}
    }

    let hacktoberfest = hacktoberfest
        .ok()
        .map(|results| results.total_count.unwrap_or_default());
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

#[cfg(test)]
mod tests {
    use super::*;

    macro_rules! passing_repo_from_remote {
        ($name:ident, $url:literal, $owner:literal, $repo:literal) => {
            #[test]
            fn $name() {
                let (owner, repo) = repo_from_remote($url).unwrap();
                assert_eq!(owner, $owner);
                assert_eq!(repo, $repo);
            }
        };
    }

    passing_repo_from_remote!(http, "http://github.com/owner/repo.git", "owner", "repo");
    passing_repo_from_remote!(https, "https://github.com/owner/repo.git", "owner", "repo");
    passing_repo_from_remote!(ssh, "git@github.com:owner/repo.git", "owner", "repo");
    passing_repo_from_remote!(
        complex_url,
        "https://github.com/us3r-nam3/r3p0-with.special.git",
        "us3r-nam3",
        "r3p0-with.special"
    );
}
