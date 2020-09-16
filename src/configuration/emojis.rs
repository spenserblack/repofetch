macro_rules! define_emojis {
    ( $( { $name:ident, $value:literal } ),* , ) => {
        $(
            pub(crate) const $name: &str = $value;
        )*


        #[cfg(test)]
        mod macro_defined_emojis {
            use paste::paste;
            use unicode_width::UnicodeWidthStr;

            $(
                paste! {
                    #[test]
                    fn [<$name:lower _size>] () {
                        assert_eq!(
                            UnicodeWidthStr::width(super::$name),
                            2,
                            concat!(
                                stringify!($name),
                                " should have a unicode width of 2",
                            ),
                        );
                    }
                }
            )*
        }
    }
}

define_emojis!{
    {URL, "🌐"},
    {STAR, "⭐"},
    {WATCHER, "👀"},
    {FORK, "🔱"},
    {ISSUE, "❗"},
    {PULL_REQUEST, "🔀"},
    {CREATED, "🐣"},
    {UPDATED, "📤"},
    {SIZE, "💽"},
    {NOT_FORK, "🥄"},
    {HELP_WANTED, "🙇"},
    {GOOD_FIRST_ISSUE, "🔰"},
    {HACKTOBERFEST, "🎃"},
}

pub(crate) const EMPTY: &str = "  ";

#[cfg(test)]
#[test]
fn empty() {
    use unicode_width::UnicodeWidthStr;

    assert_eq!(UnicodeWidthStr::width(EMPTY), 2);
}
