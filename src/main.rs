use cli::app;

fn main() {
    let matches = app().get_matches();

    let repo = matches.value_of(cli::REPO_OPTION_NAME).unwrap();
}

mod cli;
