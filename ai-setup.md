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


For a shell startup script that downloads/updates software and models, please look at
<https://github.com/laroche/laroche.github.io/blob/master/startup.sh>.


llama.cpp
---------

Install [llama.cpp](https://github.com/ggml-org/llama.cpp), see also <https://llama-cpp.com/>.
(The above startup.sh script also installs llama.cpp.)

For CPU-only setups, please also check: <https://github.com/ikawrakow/ik_llama.cpp>.


vllm
----

An alternative to llama.cpp is [vllm](https://github.com/vllm-project/vllm).
It is often used in server setups, but supports fewer llm models and often also
lacks newer features.


huggingface
-----------

- <https://huggingface.co/>
- <https://www.linkedin.com/company/huggingface/>

llama.cpp can download llm models automatically on startup, but you might
also want to download models separately from <https://huggingface.co/>.

All downloads are stored by default in <tt>~/.cache/huggingface/hub</tt>.

The huggingface software support can be installed with <tt>./startup.sh --install-hf</tt>
or via the following few lines:

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


qwen3.6 from Alibaba:

- <https://chat.qwen.ai/?thinking=true>
- <https://www.linkedin.com/company/qwen/>
- <https://github.com/QwenLM/Qwen3.6>
- <https://huggingface.co/Qwen/Qwen3.6-27B>
- <https://huggingface.co/unsloth/Qwen3.6-27B-GGUF>
- <https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF>
- <https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF>
- <https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF>
- <https://unsloth.ai/docs/models/qwen3.6>
- <https://github.com/AI-Guru/ai_services/blob/main/models/qwen3.6/README.md>

If you want to speed things up, consider changing from Q6 to Q4 and also
downgrading from Qwen3.6-27B-MTP-GGUF to Qwen3.6-35B-A3B-GGUF.


GLM:

- <https://z.ai/>
- <https://en.wikipedia.org/wiki/Z.ai>
- <https://huggingface.co/unsloth/GLM-5.1-GGUF>
- <https://unsloth.ai/docs/models/glm-5.1>
- <https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF>


hermes agent
------------

- <https://hermes-agent.nousresearch.com/>
- <https://hermes-agent.nousresearch.com/docs/>
- <https://github.com/nousresearch/hermes-agent>

For local llama.cpp configuration, use <tt>http://127.0.0.1:8001/v1</tt>.

Some commands:
<pre>
hermes update    # to update the software stack

# configuration/setup:
hermes setup
hermes model     # just the setup for llm models

hermes status
hermes doctor
hermes doctor --fix
</pre>


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
