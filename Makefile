ENV=env CHICKEN_REPOSITORY_PATH="${CHICKEN_REPOSITORY_PATH}:${.CURDIR}"
CMD=csm -static -program main -max-procs 4

all:
	${ENV} ${CMD}

clean:
	${ENV} ${CMD} -clean
