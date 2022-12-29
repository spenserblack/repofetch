repofetch.gem: repofetch.gemspec lib/** exe/**
	gem build -o repofetch.gem repofetch.gemspec

demos: tapes/*
	$(foreach tape,$(wildcard tapes/*),vhs $(tape);)

.PHONY: doc
doc:
	bundle exec yardoc

.PHONY: install
install: repofetch.gem
	gem install repofetch.gem
