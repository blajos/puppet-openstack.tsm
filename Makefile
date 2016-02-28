#NODES:=$(shell grep uvb- /etc/hosts|sed -e "s/.*\(uvb-[0-9a-zA-Z-]*\).*/\1/"|sort -u)
NODES=localhost
SSH=ssh -R8140:localhost:8140 -t

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
	$(SSH) $(SUDO_USER)@$* sudo puppet agent --no-daemonize --server localhost --verbose --onetime --noop

%_install:
	$(SSH) $(SUDO_USER)@$* sudo puppet agent --no-daemonize --server localhost --verbose --onetime
