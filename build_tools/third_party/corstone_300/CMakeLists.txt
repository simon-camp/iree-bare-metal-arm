# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

set(ethos_u_core_platform_SOURCE_DIR "${PROJECT_SOURCE_DIR}/third_party/ethos-u-core-platform/")
set(CMSIS_5_SOURCE_DIR "${PROJECT_SOURCE_DIR}/third_party/CMSIS_5/")

add_library(corstone_300 STATIC "")

target_sources(corstone_300 PRIVATE
  ${ethos_u_core_platform_SOURCE_DIR}/drivers/uart/src/uart_cmsdk_apb.c
  ${ethos_u_core_platform_SOURCE_DIR}/targets/corstone-300/retarget.c
  ${CMSIS_5_SOURCE_DIR}/Device/ARM/ARMCM4/Source/startup_ARMCM4.c
  ${CMSIS_5_SOURCE_DIR}/Device/ARM/ARMCM4/Source/system_ARMCM4.c
)

target_include_directories(corstone_300
  PUBLIC
  ${ethos_u_core_platform_SOURCE_DIR}/drivers/uart/include/
  ${CMSIS_5_SOURCE_DIR}/CMSIS/Core/Include/
  ${CMSIS_5_SOURCE_DIR}/Device/ARM/ARMCM4/Include/
  ${CMAKE_CURRENT_BINARY_DIR}
)

# Configure UART
set(UART0_BASE        "0x49303000" CACHE STRING "UART base address")
set(UART0_BAUDRATE    "115200"     CACHE STRING "UART baudrate")
set(SYSTEM_CORE_CLOCK "25000000"   CACHE STRING "System core clock (Hz)")
configure_file("${ethos_u_core_platform_SOURCE_DIR}/drivers/uart/uart_config.h.in" "${CMAKE_CURRENT_BINARY_DIR}/uart_config.h")

target_compile_definitions(corstone_300 PUBLIC -DARMCM4_FP)

# Allow ld to find generic linker script
target_link_directories(corstone_300 INTERFACE "${PROJECT_SOURCE_DIR}/build_tools/")