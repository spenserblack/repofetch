macro_rules! define_emoji {
    ($name:ident, $value:literal) => {
        pub(crate) const $name: &str = $value;
    }
}

define_emoji!{URL, "🌐"}
define_emoji!{STAR, "⭐"}
define_emoji!{WATCHER, "👀"}
define_emoji!{FORK, "🔱"}
define_emoji!{CREATED, "🐣"}
define_emoji!{UPDATED, "📤"}
define_emoji!{SIZE, "💽"}
define_emoji!{NOT_FORK, "🥄"}
define_emoji!{HACKTOBERFEST, "🎃"}

#[allow(dead_code)]
pub(crate) const EMPTY: &str = "  ";
