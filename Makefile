deploy:
	ssh isu12f-1 " \
		cd /home/isucon; \
		git checkout .; \
		git fetch; \
		git checkout $(BRANCH); \
		git reset --hard origin/$(BRANCH)"

build:
	ssh isu12f-1 " \
		cd /home/isucon/webapp/go; \
		/home/isucon/local/golang/bin/go build -o isuconquest"

go-deploy:
	scp ./webapp/go/isupipe isu12f-1:/home/isucon/webapp/go/

go-deploy-dir:
	scp -r ./webapp/go isu12f-1:/home/isucon/webapp/

restart:
	ssh isu12f-1 "sudo systemctl restart isuconquest.go.service"

mysql-deploy:
	ssh isu12f-1 "sudo dd of=/etc/mysql/mysql.conf.d/mysqld.cnf" < ./etc/mysql/mysql.conf.d/mysqld.cnf

mysql-rotate:
	ssh isu12f-1 "sudo rm -f /var/log/mysql/mysql-slow.log"

mysql-restart:
	ssh isu12f-1 "sudo systemctl restart mysql.service"

nginx-deploy:
	ssh isu12f-1 "sudo dd of=/etc/nginx/nginx.conf" < ./etc/nginx/nginx.conf
	ssh isu12f-1 "sudo dd of=/etc/nginx/sites-enabled/isuconquest.conf" < ./etc/nginx/sites-enabled/isuconquest.conf

nginx-rotate:
	ssh isu12f-1 "sudo rm -f /var/log/nginx/access.log"

nginx-reload:
	ssh isu12f-1 "sudo systemctl reload nginx.service"

nginx-restart:
	ssh isu12f-1 "sudo systemctl restart nginx.service"

nginx-log:
	ssh isu12f-1 "sudo tail -f /var/log/nginx/access.log"

nginx-error-log:
	ssh isu12f-1 "sudo tail -f /var/log/nginx/error.log"

journalctl:
	ssh isu12f-1 "sudo journalctl -xef"

env-deploy:
	ssh isu12f-1 "sudo dd of=/home/isucon/env.sh" < ./env.sh
	ssh isu12f-2 "sudo dd of=/home/isucon/env.sh" < ./env.sh

.PHONY: bench
bench:
	ssh isu12f-bench " \
		cd /home/isucon; \
		export ISUXBENCH_TARGET=172.31.37.150; \
		./bin/benchmarker --stage=prod --request-timeout=20s --initialize-request-timeout=120s"

pt-query-digest:
	ssh isu12f-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
ALPM=/user/[0-9]+/present/receive,/user/[0-9]+/gacha/draw/[0-9]+/[0-9]+,/admin/user/[0-9]+,/user/[0-9]+/present/index/1,/user/[0-9]+/item,/user/[0-9]+/gacha/index,/user/[0-9]+/gacha/index,/user/[0-9]+/card,/user/[0-9]+/reward,/user/[0-9]+/home
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh isu12f-1 "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

.PHONY: pprof
pprof:
	ssh isu12f-1 " \
		/home/isucon/local/golang/bin/go tool pprof -seconds=120 /home/isucon/webapp/go/isuconquest http://localhost:6060/debug/pprof/profile"

pprof-show:
	$(eval latest := $(shell ssh isu12f-1 "ls -rt ~/pprof/ | tail -n 1"))
	scp isu12f-1:~/pprof/$(latest) ./pprof
	go tool pprof -http=":1080" ./pprof/$(latest)

pprof-kill:
	ssh isu12f-1 "pgrep -f 'pprof' | xargs kill;"
