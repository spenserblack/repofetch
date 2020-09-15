use paste::paste;

macro_rules! define_emoji {
    ($name:ident, $value:literal) => {
        paste! {
            pub(crate) const $name: &str = $value;

            #[cfg(test)]
            #[test]
            fn [<$name:lower _size>] () {
                use unicode_width::UnicodeWidthStr;

                assert_eq!(
                    UnicodeWidthStr::width($name),
                    2,
                    concat!(stringify!($name), " should have a unicode width of 2"),
                );
            }
        }
    }
}

define_emoji!{URL, "🌐"}
define_emoji!{STAR, "⭐"}
define_emoji!{WATCHER, "👀"}
define_emoji!{FORK, "🔱"}
define_emoji!{ISSUE, "❗"}
define_emoji!{PULL_REQUEST, "🔀"}
define_emoji!{CREATED, "🐣"}
define_emoji!{UPDATED, "📤"}
define_emoji!{SIZE, "💽"}
define_emoji!{NOT_FORK, "🥄"}
define_emoji!{HELP_WANTED, "🙇"}
define_emoji!{GOOD_FIRST_ISSUE, "🔰"}
define_emoji!{HACKTOBERFEST, "🎃"}

pub(crate) const EMPTY: &str = "  ";

#[cfg(test)]
#[test]
fn empty() {
    use unicode_width::UnicodeWidthStr;

    assert_eq!(UnicodeWidthStr::width(EMPTY), 2);
}
