use anyhow::{Result, Context};
use serde::{Deserialize, Serialize};
use std::{
    fs::File,
};

type ConfigEmoji = String;

#[derive(Debug, Default, Deserialize, Serialize)]
pub(crate) struct RepofetchConfig {
    emojis: Emojis,
}

#[derive(Debug, Deserialize, Serialize)]
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
        match File::open(path) {
            Ok(f) => serde_yaml::from_reader(f).
                context("Couldn't deserialize config file"),
            Err(_) => {
                let mut f = File::create(path)
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
            created: default_created(),
            updated: default_updated(),
            size: default_size(),
            original: default_spoon(),
            hacktoberfest: default_hacktoberfest(),
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
