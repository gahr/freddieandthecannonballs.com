all:
	dune build --profile=release

clean:
	dune clean

indent:
	ocp-indent -i *.ml *.mli
