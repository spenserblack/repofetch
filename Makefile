.PHONY: install

repofetch.gem: repofetch.gemspec lib/** exe/**
	gem build -o repofetch.gem repofetch.gemspec

install: repofetch.gem
	gem install repofetch.gem
