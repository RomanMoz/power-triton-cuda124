#!/bin/bash
export USE_CUDA=1
export USE_CUDNN=1
export USE_CUFILE=0
export CUDA_HOME=/usr/local/cuda-12.4    # свой путь к toolkit
export CUDA_PATH="${CUDA_HOME}"
export PATH="${CUDA_HOME}/bin:${PATH}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

export MAX_JOBS=8
export TORCH_CUDA_ARCH_LIST="7.0"

python3 setup.py install

