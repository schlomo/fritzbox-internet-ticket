.PHONY: all build install clean commit-release release deb repo
PACKAGE=fritzbox-internet-ticket
SHELL=bash
VERSION := $(shell git rev-list HEAD --count --no-merges)
GIT_STATUS := $(shell git status --porcelain)


all: build

build:
	@echo No build required

commit-release:
ifneq ($(GIT_STATUS),)
	$(error Please commit all changes before releasing. $(shell git status 1>&2))
endif
	gbp dch --full --release --new-version=$(VERSION) --distribution stable --auto --git-author --commit
	git push

release: commit-release deb
	@latest_tag=$$(git describe --tags `git rev-list --tags --max-count=1 2>/dev/null` 2>/dev/null); \
	comparison="$$latest_tag..HEAD"; \
	if [ -z "$$latest_tag" ]; then comparison=""; fi; \
	changelog=$$(git log $$comparison --oneline --no-merges --reverse); \
	github-release schlomo/$(PACKAGE) v$(VERSION) "$$(git rev-parse --abbrev-ref HEAD)" "**Changelog**<br/>$$changelog" 'out/*.deb'; \
	git pull
	dput ppa:sschapiro/ubuntu/ppa/xenial out/$(PACKAGE)_*_source.changes

install:
	install -m 0755 -D -t $(DESTDIR)/usr/bin fritzbox-internet-ticket
	install -m 0755 -D -t $(DESTDIR)/usr/bin fritzbox-get-internet-tickets.py
	install -m 0644 -D -t $(DESTDIR)/usr/share/applications fritzbox-internet-ticket*.desktop
	install -m 0644 -D -t $(DESTDIR)/usr/share/icons/hicolor/scalable/apps fritzbox-internet-ticket*.svg

clean:
	rm -Rf debian/$(PACKAGE)* debian/files out/*

deb: clean
ifneq ($(MAKECMDGOALS), release)
	$(eval DEBUILD_ARGS := -us -uc)
endif
	debuild $(DEBUILD_ARGS) -i -b --lintian-opts --profile debian
	debuild $(DEBUILD_ARGS) -i -S --lintian-opts --profile debian
	mkdir -p out
	mv ../$(PACKAGE)*.{xz,dsc,deb,build,changes} out/
	dpkg -I out/*.deb
	dpkg -c out/*.deb

repo:
	../putinrepo.sh out/*.deb

# vim: set ts=4 sw=4 tw=0 noet :
