#!/bin/bash

set -e

export CC=/home/cheriworker/cheri/output/morello-sdk/bin/clang
export CFLAGS="--config cheribsd-morello-hybrid.cfg"
export ASMFLAGS="--config cheribsd-morello-hybrid.cfg"

build_dir="$(pwd)/build"
src_dir="$(pwd)/"

# Build project locally
cmake \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DLLVM_DIR=/home/cheriworker/cheri/output/morello-sdk/lib/cmake/llvm \
        -DClang_DIR=/home/cheriworker/cheri/output/morello-sdk/lib/cmake/clang \
        -B $build_dir \
        -S $src_dir
cmake --build $build_dir

# Spawn CHERI QEMU instance
NETDEV="user,id=net0,hostfwd=tcp::10086-:22"
$HOME/cheri/output/morello-sdk/bin/qemu-system-morello -M virt,gic-version=3 -cpu morello -m 2048 -nographic -bios edk2-aarch64-code.fd -drive if=none,file=$HOME/cheri/output/cheribsd-morello-hybrid.img,id=drv,format=raw -device virtio-blk-device,drive=drv -device virtio-net-device,netdev=net0 -netdev $NETDEV -device virtio-rng-pci

# Execute tests via CMake
cd $build_dir
ctest
