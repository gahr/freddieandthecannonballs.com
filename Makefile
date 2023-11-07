REPO=fossil info | grep ^repository | awk '{print $$2}'
CMD=csm -static -program main -max-procs 4

all:
	${CMD}

clean:
	${CMD} -clean

git:
	@if [ -e git-import ]; then \
	    echo "The 'git-import' directory already exists"; \
	    exit 1; \
	fi; \
	git init -b master git-import && cd git-import && \
	fossil export --git --rename-trunk master --repository `${REPO}` | \
	git fast-import && git reset --hard HEAD && \
	git remote add origin git@github.com:gahr/freddieandthecannonballs.com.git && \
	git push -f origin master && \
	cd .. && rm -rf git-import

