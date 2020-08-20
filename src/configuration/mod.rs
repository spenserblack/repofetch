use anyhow::{Result, Context};
use serde::{Deserialize, Serialize};
use std::{
    fs::File,
    path::Path,
};

type ConfigEmoji = String;
type ConfigLabel = String;

#[derive(Debug, Default, Deserialize, Serialize)]
pub(crate) struct RepofetchConfig {
    pub(crate) emojis: Emojis,
    pub(crate) labels: Labels,
}

#[derive(Debug, Deserialize, Serialize)]
pub(crate) struct Emojis {
    #[serde(default = "default_url")]
    pub(crate) url: ConfigEmoji,

    #[serde(default = "default_star")]
    pub(crate) star: ConfigEmoji,

    #[serde(default = "default_watcher")]
    pub(crate) subscriber: ConfigEmoji,

    #[serde(default = "default_fork")]
    pub(crate) fork: ConfigEmoji,

    #[serde(default = "default_issue")]
    pub(crate) issue: ConfigEmoji,

    #[serde(default = "default_pr")]
    pub(crate) pull_request: ConfigEmoji,

    #[serde(default = "default_created")]
    pub(crate) created: ConfigEmoji,

    #[serde(default = "default_updated")]
    pub(crate) updated: ConfigEmoji,

    #[serde(default = "default_size")]
    pub(crate) size: ConfigEmoji,

    #[serde(default = "default_spoon")]
    pub(crate) original: ConfigEmoji,

    #[serde(default = "default_help_wanted")]
    pub(crate) help_wanted: ConfigEmoji,

    #[serde(default = "default_first_issue")]
    pub(crate) good_first_issue: ConfigEmoji,

    #[serde(default = "default_hacktoberfest")]
    pub(crate) hacktoberfest: ConfigEmoji,

    #[serde(default = "default_empty")]
    pub(crate) placeholder: ConfigEmoji,
}

#[derive(Debug, Deserialize, Serialize)]
pub(crate) struct Labels {
    #[serde(default = "help_wanted_label")]
    pub(crate) help_wanted: ConfigLabel,

    #[serde(default = "good_first_issue_label")]
    pub(crate) good_first_issue: ConfigLabel,
}

impl RepofetchConfig {
    pub fn new<P: AsRef<Path>>(path: P) -> Result<RepofetchConfig> {
        match File::open(&path) {
            Ok(f) => serde_yaml::from_reader(f)
                .context("Couldn't deserialize config file"),
            Err(_) => {
                let f = File::create(&path)
                    .context("Couldn't open config file to write")?;
                let default_config = RepofetchConfig::default();
                serde_yaml::to_writer(f, &default_config)
                    .context("Couldn't serialize initial config file")?;
                Ok(default_config)
            }
        }
    }
}

impl Default for Emojis {
    fn default() -> Emojis {
        Emojis {
            url: default_url(),
            star: default_star(),
            subscriber: default_watcher(),
            fork: default_fork(),
            issue: default_issue(),
            pull_request: default_pr(),
            created: default_created(),
            updated: default_updated(),
            size: default_size(),
            original: default_spoon(),
            help_wanted: default_help_wanted(),
            good_first_issue: default_first_issue(),
            hacktoberfest: default_hacktoberfest(),
            placeholder: default_empty(),
        }
    }
}

impl Default for Labels {
    fn default() -> Labels {
        Labels {
            help_wanted: help_wanted_label(),
            good_first_issue: good_first_issue_label(),
        }
    }
}

fn default_url() -> String {
    emojis::URL.into()
}

fn default_star() -> String {
    emojis::STAR.into()
}

fn default_watcher() -> String {
    emojis::WATCHER.into()
}

fn default_fork() -> String {
    emojis::FORK.into()
}

fn default_issue() -> String {
    emojis::ISSUE.into()
}

fn default_pr() -> String {
    emojis::PULL_REQUEST.into()
}

fn default_created() -> String {
    emojis::CREATED.into()
}

fn default_updated() -> String {
    emojis::UPDATED.into()
}

fn default_size() -> String {
    emojis::SIZE.into()
}

fn default_spoon() -> String {
    emojis::NOT_FORK.into()
}

fn default_help_wanted() -> String {
    emojis::HELP_WANTED.into()
}

fn default_first_issue() -> String {
    emojis::GOOD_FIRST_ISSUE.into()
}

fn default_hacktoberfest() -> String {
    emojis::HACKTOBERFEST.into()
}

fn default_empty() -> String {
    emojis::EMPTY.into()
}

fn help_wanted_label() -> String {
    "help wanted".into()
}

fn good_first_issue_label() -> String {
    "good first issue".into()
}

pub(crate) mod emojis;
