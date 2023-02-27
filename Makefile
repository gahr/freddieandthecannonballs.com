REPO=fossil info | grep ^repository | awk '{print $$2}'
ENV=env CHICKEN_REPOSITORY_PATH="${CHICKEN_REPOSITORY_PATH}:${.CURDIR}"
CMD=csm -static -program main -max-procs 4

all:
	${ENV} ${CMD}

clean:
	${ENV} ${CMD} -clean

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

