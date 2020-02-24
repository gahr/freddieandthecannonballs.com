all:
	dune build --profile=release

clean:
	rm -rf _build

indent:
	ocp-indent -i *.ml *.mli
