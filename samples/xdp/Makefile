# Build BPF target:
# * optimization level 2 required, unknown opcode 8d on bpftool prog load
# otherwise
# * include debugging symbols (-g) to pretty print map data with `pbftool map
# dump`
build:
	clang \
		-target bpf \
		-O2 \
		-g \
		-o hello-xdp.bcc.o -c hello-xdp.bcc.c

