use anyhow::{Result, Context};
use serde::Deserialize;
use std::{
    fs::File,
};

type ConfigEmoji = String;

#[derive(Debug, Deserialize)]
pub(crate) struct RepofetchConfig {
    emojis: Emojis,
}

#[derive(Debug, Deserialize)]
pub(crate) struct Emojis {
    #[serde(default = "default_url")]
    url: ConfigEmoji,

    #[serde(default = "default_star")]
    star: ConfigEmoji,

    #[serde(default = "default_watcher")]
    subscriber: ConfigEmoji,

    #[serde(default = "default_fork")]
    fork: ConfigEmoji,

    #[serde(default = "default_created")]
    created: ConfigEmoji,

    #[serde(default = "default_updated")]
    updated: ConfigEmoji,

    #[serde(default = "default_size")]
    size: ConfigEmoji,

    #[serde(default = "default_spoon")]
    original: ConfigEmoji,

    #[serde(default = "default_hacktoberfest")]
    hacktoberfest: ConfigEmoji,
}

impl RepofetchConfig {
    pub fn new(path: &str) -> Result<RepofetchConfig> {
        let f = File::open(path)
            .context("Couldn't open config file")?;
        serde_yaml::from_reader(f)
            .context("Couldn't deserialize config file")
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

fn default_hacktoberfest() -> String {
    emojis::HACKTOBERFEST.into()
}

fn default_empty() -> String {
    emojis::EMPTY.into()
}

pub(crate) mod emojis;
