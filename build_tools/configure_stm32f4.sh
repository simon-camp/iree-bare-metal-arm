#!/bin/bash

# Copyright 2021 Fraunhofer-Gesellschaft zur Förderung der angewandten Forschung e.V.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# Bash script to configure a build for stm32f4.

if [[ $# -ne 2 ]] ; then
  echo "Usage: $0 <lib> <device>"
  exit 1
fi

# Set linker flags
case $1 in
  cmsis)
    echo "Building with CMSIS"
    export CUSTOM_ARM_LINKER_FLAGS="-lnosys"
    ;;

  libopencm3)
    echo "Building with libopencm3"
    export CUSTOM_ARM_LINKER_FLAGS="-nostartfiles"
    ;;

  *)
    echo "Unknown lib. Use 'cmsis' or 'libopencm3"
    exit 1
    ;;
esac

# Set path to linker script
case $2 in
  stm32f407)
    echo "Building for STM32F407"
    if [ "$1" == "cmsis" ]; then
      export PATH_TO_LINKER_SCRIPT="`realpath ../build_tools/stm32f407-cmsis.ld`"
    else
      export PATH_TO_LINKER_SCRIPT="`realpath ../build_tools/stm32f407-libopencm3.ld`"
    fi
    ;;

  stm32f4xx)
    echo "Building for STM32F4xx, high memory"
    if [ "$1" == "cmsis" ]; then
      export PATH_TO_LINKER_SCRIPT="`realpath ../build_tools/stm32f4xx-highmem-cmsis.ld`"
    else
      export PATH_TO_LINKER_SCRIPT="`realpath ../build_tools/stm32f4xx-highmem-libopencm3.ld`"
    fi
    ;;

  *)
    echo "Unknown device. Use 'stm32f407' or 'stm32f4xx"
    exit 1
    ;;
esac

# Set the path to the GNU Arm Embedded Toolchain
export PATH_TO_ARM_TOOLCHAIN="/usr/local/gcc-arm-none-eabi-10.3-2021.10"

# Set the path to the IREE host binary
export PATH_TO_IREE_HOST_BINARY_ROOT="`realpath ../build-iree-host-install`"

# Check paths
if ! [ -f "$PATH_TO_LINKER_SCRIPT" ]; then
  echo "Expected the path to linker script to be set correctly (got '$PATH_TO_LINKER_SCRIPT'): can't find linker script"
  exit 1
fi

if ! [ -d "$PATH_TO_IREE_HOST_BINARY_ROOT/bin/" ]; then
  echo "Expected the path to IREE host binary to be set correctly (got '$PATH_TO_IREE_HOST_BINARY_ROOT'): can't find bin subdirectory"
  exit 1
fi

# Configure project
cmake -GNinja \
      -DBUILD_WITH_CMSIS=ON \
      -DCMAKE_TOOLCHAIN_FILE="`realpath ../build_tools/cmake/arm.toolchain.cmake`" \
      -DARM_TOOLCHAIN_ROOT="${PATH_TO_ARM_TOOLCHAIN}" \
      -DARM_CPU="armv7e-m" \
      -DIREE_HAL_DRIVERS_TO_BUILD="VMVX_Sync;DYLIB_Sync" \
      -DIREE_HOST_BINARY_ROOT="${PATH_TO_IREE_HOST_BINARY_ROOT}" \
      -DCUSTOM_ARM_LINKER_FLAGS="${CUSTOM_ARM_LINKER_FLAGS}" \
      -DLINKER_SCRIPT="${PATH_TO_LINKER_SCRIPT}" \
      ..