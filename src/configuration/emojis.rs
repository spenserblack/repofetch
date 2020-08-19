macro_rules! define_emoji {
    ($name:ident, $value:literal, $test_name:ident) => {
        pub(crate) const $name: &str = $value;

        #[cfg(test)]
        #[test]
        fn $test_name() {
            use unicode_width::UnicodeWidthStr;

            assert_eq!(UnicodeWidthStr::width($name), 2);
        }
    }

}

define_emoji!{URL, "🌐", url}
define_emoji!{STAR, "⭐", star}
define_emoji!{WATCHER, "👀", watcher}
define_emoji!{FORK, "🔱", fork}
define_emoji!{ISSUE, "❗", issue}
define_emoji!{PULL_REQUEST, "🔀", pr}
define_emoji!{CREATED, "🐣", created}
define_emoji!{UPDATED, "📤", updated}
define_emoji!{SIZE, "💽", size}
define_emoji!{NOT_FORK, "🥄", spoon}
define_emoji!{HACKTOBERFEST, "🎃", jack_lantern}

pub(crate) const EMPTY: &str = "  ";

#[cfg(test)]
#[test]
fn empty() {
    use unicode_width::UnicodeWidthStr;

    assert_eq!(UnicodeWidthStr::width(EMPTY), 2);
}
