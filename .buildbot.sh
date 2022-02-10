#!/bin/bash

set -e

build_dir="$(pwd)/build"
src_dir="$(pwd)"
cheri_dir="/home/buildbot/cheri/output"

export CC=$cheri_dir/morello-sdk/bin/clang
export CFLAGS="--config cheribsd-morello-hybrid.cfg"
export ASMFLAGS="--config cheribsd-morello-hybrid.cfg"

# Build project locally
cmake \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DLLVM_DIR=$cheri_dir/morello-sdk/lib/cmake/llvm \
        -DClang_DIR=$cheri_dir/morello-sdk/lib/cmake/clang \
        -B $build_dir \
        -S $src_dir
cmake --build $build_dir

# Spawn CHERI QEMU instance
NETDEV="user,id=net0,hostfwd=tcp::10086-:22"
$cheri_dir/morello-sdk/bin/qemu-system-morello \
    -M virt,gic-version=3 \
    -cpu morello \
    -m 2048 \
    -nographic \
    -bios edk2-aarch64-code.fd \
    -drive if=none,file=$cheri_dir/cheribsd-morello-hybrid.img,id=drv,format=raw \
    -device virtio-blk-device,drive=drv \
    -device virtio-net-device,netdev=net0 \
    -netdev $NETDEV \
    -device virtio-rng-pci

# Execute tests via CMake
cd $build_dir
ctest
