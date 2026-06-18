#!/bin/bash

# User configuration part:

#MODEL="unsloth/North-Mini-Code-1.0-GGUF:UD-Q8_K_XL"

#MODEL="unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q6_K_XL"
#MODEL="unsloth/Qwen3.6-27B-GGUF:UD-Q6_K_XL"
#MODEL="unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q6_K_XL"
#MODEL="unsloth/Qwen3-Coder-Next-GGUF:UD-Q4_K_XL"

MODEL="unsloth/GLM-4.7-Flash-GGUF:UD-Q6_K_XL"

SERVER_HOST=127.0.0.1
#SERVER_HOST=0.0.0.0
SERVER_PORT=8080

# Number of CPUs available on your local hardware:
#THREADS="-1"
#THREADS="12"
THREADS="$(nproc)"

# Additional arguments to llama.cpp:
EXTRA_ARGS=""
EXTRA_ARGS="$EXTRA_ARGS --timeout 3600"
#EXTRA_ARGS="$EXTRA_ARGS --cache-ram 0"
# f16 is default, maybe change to q8_0:
#EXTRA_ARGS="$EXTRA_ARGS --cache-type-v f16  --cache-type-k f16"
#EXTRA_ARGS="$EXTRA_ARGS --cache-type-v q8_0 --cache-type-k q8_0"

# Enable support for Nvidia Cuda?
CUDA=0


# -------------------------------------------------------------
# Below is implementation, no more configuration.

if test "X$1" = "X--install-hf" ; then
  echo "Installing huggingface support."
  sudo apt-get update
  sudo apt-get install -y python3-venv
  python3 -m venv venv
  . venv/bin/activate
  pip3 install huggingface_hub hf_transfer
  exit 0
fi


UPDATE_SOFTWARE=0
if ! test -d llama.cpp ; then
  UPDATE_SOFTWARE=1
fi
if test "X$1" = "X--update" ; then
  UPDATE_SOFTWARE=1
  shift
fi

if test $UPDATE_SOFTWARE = 1 ; then
  sudo apt-get update
  sudo apt-get install -y pciutils build-essential cmake curl libcurl4-openssl-dev
  if ! test -d llama.cpp ; then
    git clone https://github.com/ggml-org/llama.cpp
    #git submodule update --init --recursive
  else
    rm -fr llama.cpp/build
    pushd llama.cpp
      git pull
    popd
  fi
  if ! test -d llama.cpp ; then
    echo "llama.cpp was not downloaded. Exiting."
    exit 1
  fi
  CUDA_PARAM=""
  if test $CUDA = 1 ; then
    CUDA_PARAM="-DGGML_CUDA=ON"
  fi
  cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF $CUDA_PARAM
  #-DGGML_BLAS=OFF
  cmake --build llama.cpp/build --config Release -j --clean-first --target llama-cli llama-mtmd-cli llama-server llama-gguf-split llama-bench
  cp llama.cpp/build/bin/llama-* llama.cpp
fi

if test "X$1" = "X--bench" ; then
  shift
  ./llama.cpp/llama-bench -hf $MODEL -t $THREADS
  exit 0
fi

if echo $MODEL | grep -q North-Mini-Code ; then
  ./llama.cpp/llama-server \
    -hf $MODEL \
    --temp 1.0 --top-p 0.95 \
    $EXTRA_ARGS \
    --threads $THREADS --host $SERVER_HOST --port $SERVER_PORT
elif echo $MODEL | grep -q Qwen ; then
  MODEL_EXTRA_ARGS=""
  if echo $MODEL | grep -q MTP-GGUF ; then
    MODEL_EXTRA_ARGS="$MODEL_EXTRA_ARGS --flash-attn on --parallel 1 --spec-type draft-mtp --spec-draft-n-max 2"
  fi
  ./llama.cpp/llama-server \
    -hf $MODEL \
    --temp 0.6 --top-k 20 --top-p 0.95 --min-p 0.00 --presence-penalty 0.0 \
    --reasoning on --chat-template-kwargs '{"preserve_thinking":true}' \
    --chat-template-file qwen3.6_chat_template.jinja \
    $MODEL_EXTRA_ARGS $EXTRA_ARGS \
    --threads $THREADS --host $SERVER_HOST --port $SERVER_PORT
elif echo $MODEL | grep -q GLM ; then
  ./llama.cpp/llama-server \
    -hf $MODEL --alias "unsloth/GLM-4.7-Flash" \
    --temp 0.7 --top-p 1.0 --min-p 0.01 --repeat-penalty 1.0 \
    $EXTRA_ARGS \
    --threads $THREADS --host $SERVER_HOST --port $SERVER_PORT
fi

# 2>&1 | tee startup.sh.LOG.$BASHPID

# sudo nano /etc/security/limits.conf
# * soft memlock unlimited
# * hard memlock unlimited
# check with: ulimit -l

#    --image-min-tokens 1024 \
#    --no-mmap --mlock \
#    --no-mmproj \

#    --temp 1.0 \
#    --presence_penalty 1.5 \
# For precise coding tasks, change to:
#    --temp 0.6 \
#    --presence_penalty 0.0 \

# Instead of -hf param:
# --model unsloth/Qwen3.6-27B-GGUF/Qwen3.6-27B-UD-Q6_K_XL.gguf \
# --mmproj unsloth/Qwen3.6-27B-GGUF/mmproj-BF16.gguf \
# --alias unsloth/Qwen3.6-27B-GGUF \
# --model unsloth/Qwen3.6-35B-A3B-GGUF/Qwen3.6-35B-A3B-UD-Q6_K_XL.gguf \
# --mmproj unsloth/Qwen3.6-35B-A3B-GGUF/mmproj-BF16.gguf \
# --alias unsloth/Qwen3.6-35B-A3B-GGUF \

