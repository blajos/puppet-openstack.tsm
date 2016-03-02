NODES:=$(shell puppet cert list --all|cut -f2 -d\")
SSH=ssh -t

commit:
	git add -A
	git commit -a || true
	git push --all

test:
	puppet agent --no-daemonize --server localhost --verbose --onetime --noop --test

install:
	puppet agent --no-daemonize --server localhost --verbose --onetime

test_all: $(NODES:=_test)

install_all: $(NODES:=_install)

%_test:
	$(SSH) $* sudo puppet agent --test --noop || true

%_install:
	$(SSH) $* sudo puppet agent --test || true
