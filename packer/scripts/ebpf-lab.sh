#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

dnf config-manager --set-enabled crb
dnf install -y epel-release epel-next-release

# Install BCC prerequisites
# https://github.com/iovisor/bcc/blob/master/INSTALL.md
dnf install -y bison cmake ethtool flex git iperf3 libstdc++-devel python3-netaddr \
               python3-pyroute2 python3-pip python3-docutils gcc gcc-c++ make \
               zlib-devel elfutils-libelf-devel clang-15.0.7 clang-devel-15.0.7 \
               llvm-15.0.7 llvm-devel-15.0.7 llvm-static-15.0.7 ncurses-devel zip unzip netperf

# Lock Clang and LLVM versions
dnf install -y python3-dnf-plugin-versionlock
yum versionlock llvm*
yum versionlock clang*

# LLVM required because of issue:
# https://github.com/llvm/llvm-project/issues/61436

# Install BCC from source
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build

# LLVM should always link shared library
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_LLVM_SHARED=1
make -j10
make install

# Install bpftool
# https://github.com/libbpf/bpftool
cd $HOME
git clone --recurse-submodules https://github.com/libbpf/bpftool.git
cd bpftool/src; make install
cd ../docs; make install

# Install bpftrace
# https://github.com/iovisor/bpftrace/blob/master/INSTALL.md
cd $HOME
dnf install -y bcc-devel systemtap-sdt-devel binutils-devel libbpf-devel vim-common \
               libpcap-devel gtest-devel gmock-devel cereal-devel asciidoctor dwarves \
               elfutils-devel
git clone https://github.com/iovisor/bpftrace --recurse-submodules
cd bpftrace
mkdir build; cd build
../build-libs.sh
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j8
make install

# Prepare eBPF lab with samples
hostnamectl hostname ebpf-lab
cd $HOME
git clone https://github.com/in0rdr/ebpf-lab.git
