#!/usr/bin/env python3

# Adapted from
# https://github.com/capablevms/cheri-examples/blob/master/tests/run_cheri_examples.py

import argparse
import importlib.util
import os
import sys

from pathlib import Path

test_scripts_dir = str(Path(importlib.util.find_spec("run_tests_common").origin).parent.absolute())
sys.path = sys.path[sys.path.index(test_scripts_dir):]

from run_tests_common import boot_cheribsd, run_tests_main

def run_tests(qemu: boot_cheribsd.QemuCheriBSDInstance, args: argparse.Namespace) -> bool:
    if args.sysroot_dir is not None:
        boot_cheribsd.set_ld_library_path_with_sysroot(qemu)
    boot_cheribsd.info("Running tests for cheri-morello-compartmentalisation")

    # Run the tests according to the architecture
    return os.system(f"cd {args.build-dir}/build && ctest") == 0

if __name__ == '__main__':
    run_tests_main(test_function=run_tests, need_ssh=True, should_mount_builddir=False)
