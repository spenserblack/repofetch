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

.PHONY: package-deb
package-deb: repofetch.gem
	fpm -s gem -t deb --gem-package-name-prefix ruby --gem-disable-dependency faraday-retry --gem-disable-dependency actionview --depends 'ruby-actionview > 2:5.0.0.0' repofetch.gem
