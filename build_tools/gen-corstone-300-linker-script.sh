#!/bin/bash

arm-none-eabi-gcc -E -P -x c -C -o corstone-300-plattform.ld ../third_party/ethos-u-core-platform/targets/corstone-300/platform.ld
