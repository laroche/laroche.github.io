---
title: AI setup
author: Florian La Roche
linkcolor: blue
---

experimental AI setup
=====================

If you can privately afford some more hardware, consider looking into
[NVIDIA DGX Spark](https://www.hardwareluxx.de/index.php/artikel/hardware/komplettsysteme/68662-nvidia-dgx-spark-der-ki-mini-pc-im-praxiseinsatz.html).
Hier also a German article [Heise-News about Nvidia DGX Spark](https://www.heise.de/news/Duell-der-KI-Kisten-Nvidia-DGX-Spark-vs-AMD-Strix-Halo-11079206.html).
Or as an alternative, check out AMD Strix Halo hardware.

Other links:

- <https://github.com/AI-Guru/ai_services> from Dr. Tristan Behrens
- <https://clarifai.com/blog/ilama.cpp>
- TODO: <https://github.com/AI-Guru/ai_services/commit/394927cd2a1e90773b25fb12f1173a5dbe40ce66>
- TODO: <https://www.reddit.com/r/LocalLLaMA/comments/1tg6j9u/benchmarking_the_new_b9200_update_optimizing_qwen/?tl=de>
- TODO: look into --metrics with prometheus-compatible data: <https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md>
- TODO: check out presets for several HF models: <https://github.com/ggml-org/llama.cpp/blob/master/docs/preset.md>


llama.cpp
---------

Install [llama.cpp](https://github.com/ggml-org/llama.cpp), see also <https://llama-cpp.com/>:
<pre>
sudo apt-get update
sudo apt-get install -y pciutils build-essential cmake curl libcurl4-openssl-dev
git clone https://github.com/ggml-org/llama.cpp
cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF #-DGGML_CUDA=ON
cmake --build llama.cpp/build --config Release -j --clean-first --target llama-cli llama-mtmd-cli llama-server llama-gguf-split
cp llama.cpp/build/bin/llama-* llama.cpp
</pre>

For CPU-only setups, please also check: <https://github.com/ikawrakow/ik_llama.cpp>.


vllm
----

An alternative to llama.cpp is [vllm](https://github.com/vllm-project/vllm).
It is often used in server setups, but supports fewer llm models and often also
lacks newer features.


huggingface
-----------

llama.cpp can download llm models automatically on startup, but you might
also want to download models separately from <https://huggingface.co/>:

<pre>
sudo apt-get update
sudo apt-get install -y python3-venv
python3 -m venv venv
. venv/bin/activate
pip3 install huggingface_hub hf_transfer
hf cache list
hf models list
MODEL="unsloth/Qwen3.6-27B-MTP-GGUF"
#MODEL="unsloth/Qwen3.6-27B-GGUF"
#MODEL="unsloth/Qwen3.6-35B-A3B-GGUF"
hf models info $MODEL
hf download $MODEL --include "*mmproj-BF16*" --include "*UD-Q6_K_XL*"
</pre>


large language model (llm)
--------------------------

Depending on hardware and on task, you might choose between different llm models.
qwen3.6 is pretty new and has good quality.


qwen3.6
-------

See also:

- <https://chat.qwen.ai/?thinking=true>
- <https://github.com/QwenLM/Qwen3.6>
- <https://huggingface.co/Qwen/Qwen3.6-27B>
- <https://huggingface.co/unsloth/Qwen3.6-27B-GGUF>
- <https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF>
- <https://unsloth.ai/docs/models/qwen3.6>
- <https://github.com/AI-Guru/ai_services/blob/main/models/qwen3.6/README.md>


Start script:
<pre>
#!/bin/bash

SERVERHOST="127.0.0.1"
#SERVERHOST="0.0.0.0"
SERVERPORT="8080"

# Number of threads to run concurrently. Adjust to local hardware.
THREADS="12"

MODEL="unsloth/Qwen3.6-27B-MTP-GGUF"
#MODEL="unsloth/Qwen3.6-27B-GGUF"
#MODEL="unsloth/Qwen3.6-35B-A3B-GGUF"

./llama.cpp/llama-server \
    -hf $MODEL:UD-Q6_K_XL \
    --temp 0.6 \
    --top-k 20 \
    --top-p 0.95 \
    --min-p 0.00 \
    --presence-penalty 0.0 \
    --spec-type draft-mtp --spec-draft-n-max 2 \
    --reasoning on \
    --chat-template-kwargs '{"preserve_thinking":true}' \
    --threads $THREADS \
    --host $SERVERHOST \
    --port $SERVERPORT

    # 2>&1 | tee startup.sh.LOG.$BASHPID

#    --image-min-tokens 1024 \
#    --no-mmap --mlock \
#    --ctx-size 81920 \
#    --ctx-size 262144 \
#    -ctk q4_0 -ctv q4_0 \
#    --parallel -1 \
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
</pre>

If you want to speed things up, consider changing from Q6 to Q4 and also
downgrading from Qwen3.6-27B-MTP-GGUF to Qwen3.6-35B-A3B-GGUF.


hermes agent
------------

- <https://hermes-agent.nousresearch.com/>
- <https://hermes-agent.nousresearch.com/docs/>
- <https://github.com/nousresearch/hermes-agent>


opencode
--------

See <https://opencode.ai/>.
<pre>
npm install -g @opencode/cli
opencode config set model http://localhost:8080/v1
opencode config set api-key "not-needed"
opencode
</pre>


openclaw
--------

Not running this myself, but you might want to check out:
<https://openclaw.ai/>


sashiko
-------

[Sashiko](https://github.com/sashiko-dev/sashiko) is an agentic Linux kernel code review system.


[Impressum](/impressum)
