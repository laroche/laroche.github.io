---
title: AI setup
author: Florian La Roche
linkcolor: blue
---

experimental AI setup
=====================

I am running this setup without any GPU only with a normal CPU on a local PC at home
with 64 GB of RAM (32 GB should also be ok).

If you can afford some more hardware, consider looking into
[NVIDIA DGX Spark](https://www.hardwareluxx.de/index.php/artikel/hardware/komplettsysteme/68662-nvidia-dgx-spark-der-ki-mini-pc-im-praxiseinsatz.html).
Hier also some German [Heise-News about Nvidia DGX Spark](https://www.heise.de/news/Duell-der-KI-Kisten-Nvidia-DGX-Spark-vs-AMD-Strix-Halo-11079206.html).


llama.cpp
---------

Install [llama.cpp](https://github.com/ggml-org/llama.cpp), see also <https://llama-cpp.com/>:
<pre>
sudo apt-get update
sudo apt-get install -y pciutils build-essential cmake curl libcurl4-openssl-dev
git clone https://github.com/ggml-org/llama.cpp
cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF
cmake --build llama.cpp/build --config Release -j --clean-first --target llama-cli llama-mtmd-cli llama-server llama-gguf-split
cp llama.cpp/build/bin/llama-* llama.cpp
</pre>
(As an alternative, look into running [vllm](https://github.com/vllm-project/vllm).)

Install qwen3.6 from huggingface:
<pre>
sudo apt-get update
sudo apt-get install -y python3-venv
python3 -m venv venv
. venv/bin/activate
pip3 install huggingface_hub hf_transfer
hf cache list
hf models list
hf models info unsloth/Qwen3.6-27B-MTP-GGUF
MODEL="unsloth/Qwen3.6-27B-MTP-GGUF"
#MODEL="unsloth/Qwen3.6-27B-GGUF"
#MODEL="unsloth/Qwen3.6-35B-A3B-GGUF"
hf download $MODEL --include "*mmproj-BF16*" --include "*UD-Q6_K_XL*"
</pre>

See also:

- <https://chat.qwen.ai/?thinking=true>
- <https://huggingface.co/Qwen/Qwen3.6-27B>
- <https://unsloth.ai/docs/models/qwen3.6>


Start script (opens a server on your local machine on port 8001 and
uses 12 threads, which you might want to adjust for your local hardware):
<pre>
#!/bin/bash

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
    --threads 12 \
    --host 0.0.0.0 \
    --port 8001

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


opencode
--------

<pre>
npm install -g @opencode/cli
opencode config set model http://localhost:8080/v1
opencode config set api-key "not-needed"
opencode
</pre>


[Impressum](/impressum)

