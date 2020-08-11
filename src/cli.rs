use clap::{crate_description, crate_name, crate_version, App, Arg};

pub(crate) const REPO_OPTION_NAME: &str = "repository";

pub(crate) fn app<'a, 'b>() -> App<'a, 'b> {
    App::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .arg(
            Arg::with_name(REPO_OPTION_NAME)
                .index(1)
                .help("Your GitHub repository (`username/repo`)")
        )
}
