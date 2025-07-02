###############################################################################
# Copyright (c) Advanced Micro Devices, Inc. All rights reserved.
#
# SPDX-License-Identifier: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
###############################################################################

###############################################################################
# DEFAULT BUILD TYPE
###############################################################################
set(CMAKE_BUILD_TYPE "Release" CACHE STRING
      "build type: Release, Debug, RelWithDebInfo, MinSizeRel")


#############################################################################
# SET GPU ARCHITECTURES
#############################################################################
include(cmake/rocm_local_targets.cmake)

set(DEFAULT_GPUS
    gfx90a:xnack-;
    gfx90a:xnack+;
    gfx942:xnack-;
    gfx942:xnack+;
    gfx950:xnack-;
    gfx950:xnack+)

if (BUILD_LOCAL_GPU_TARGET_ONLY)
  message(STATUS "Building only for local GPU target")
  if (COMMAND rocm_local_targets)
    rocm_local_targets(DEFAULT_GPUS)
  else()
    message(WARNING "Unable to determine local GPU targets. Falling back to default GPUs.")
  endif()
endif()

set(CURRENT_GPU_TARGETS "${DEFAULT_GPUS}" CACHE STRING
    "Target default GPUs if CURRENT_GPU_TARGETS is not defined.")

if (COMMAND rocm_check_target_ids)
  message(STATUS "Checking for ROCm support for GPU targets: " "${CURRENT_GPU_TARGETS}")
  rocm_check_target_ids(SUPPORTED_GPUS TARGETS ${CURRENT_GPU_TARGETS})
else()
  message(WARNING "Unable to check for supported GPU targets.")
  set(SUPPORTED_GPUS ${CURRENT_GPU_TARGETS})
endif()

set(GPU_TARGETS "${SUPPORTED_GPUS}" CACHE STRING "GPU architectures to compile for")

message(STATUS "Compiling for ${GPU_TARGETS}")

###############################################################################
# GLOBAL COMPILE FLAGS
###############################################################################
foreach (root ${hip_ROOT} $ENV{hip_ROOT} ${ROCM_ROOT} $ENV{ROCM_ROOT} ${ROCM_PATH} $ENV{ROCM_PATH})
  if (IS_DIRECTORY ${root})
    list(PREPEND CMAKE_PREFIX_PATH ${root})
  endif()
endforeach()
if (NOT DEFINED CMAKE_CXX_COMPILER)
  find_program(CMAKE_CXX_COMPILER hipcc PATHS /opt/rocm)
endif()
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -ggdb")

