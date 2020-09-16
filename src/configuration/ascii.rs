macro_rules! define_ascii {
    ($( { $name:ident, $file:literal } )* ,) => {
        $(
            pub(crate) const $name: &str = include_str!(
                concat!(env!("CARGO_MANIFEST_DIR"), "/", $file),
            );
        )*

        #[cfg(test)]
        mod sizes {
            use paste::paste;
            use more_asserts::*;

            const MAX_WIDTH: usize = 40;
            const MAX_HEIGHT: usize = 20;

            $(
                paste! {
                    #[test]
                    fn [<$name:lower _width>] () {
                        for (index, line) in super::$name.lines().enumerate() {
                            let width = line.len();
                            assert_le!(
                                width,
                                MAX_WIDTH,
                                "{} was too wide at line {}: {} > {}",
                                $file,
                                index,
                                width,
                                MAX_WIDTH,
                            );
                        }
                    }

                    #[test]
                    fn [<$name:lower _height>] () {
                        let height = super::$name.lines().count();
                        assert_le!(
                            height,
                            MAX_HEIGHT,
                            "{} had too many lines: {} > {}",
                            $file,
                            height,
                            MAX_HEIGHT,
                        );
                    }
                }
            )*
        }
    }
}

define_ascii!{
    {GITHUB, "ascii/github.ascii"},
}
