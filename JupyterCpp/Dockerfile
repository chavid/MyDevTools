FROM devcpp20:v12.2

# For the conversion to pdf

USER root
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apt-utils
RUN apt-get install -y pandoc
RUN apt-get install -y texlive-xetex texlive-fonts-recommended texlive-plain-generic
RUN rm -rf /var/lib/apt/lists/*

# Return to user dev

USER dev

# Download GTP4ALL model

RUN mkdir -p ~/.cache/gpt4all
ARG LLM=orca-mini-3b-gguf2-q4_0.gguf
RUN wget https://gpt4all.io/models/gguf/$LLM -O ~/.cache/gpt4all/$LLM
ARG LLM=all-MiniLM-L6-v2-f16.gguf
RUN wget https://gpt4all.io/models/gguf/$LLM -O ~/.cache/gpt4all/$LLM

# Miniconda3 with Python 3.11

RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_24.1.2-0-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN ~/miniconda3/bin/conda init bash
COPY miniconda3_eval.bash .

# Conda installations

RUN ./miniconda3_eval.bash conda config --add channels conda-forge
RUN ./miniconda3_eval.bash conda config --set channel_priority strict

RUN ./miniconda3_eval.bash conda install -y jupyterlab
RUN ./miniconda3_eval.bash conda install -y xeus-cling
RUN ./miniconda3_eval.bash conda install -y nbdime

# Pip installations

RUN ./miniconda3_eval.bash python -m pip install nbclassic # classical notebooks
RUN ./miniconda3_eval.bash python -m pip install rise      # rise for classical notebooks

RUN ./miniconda3_eval.bash python -m pip install jupytercards==2.7.0a4
RUN ./miniconda3_eval.bash python -m pip install jupyterquiz==2.7.0a4

RUN ./miniconda3_eval.bash python -m pip install jupytext
RUN mkdir -p /home/dev/miniconda3/etc/jupyter/labconfig
COPY jupytext.toml /home/dev/jupytext.toml
COPY labconfig/default_setting_overrides.json /home/dev/miniconda3/etc/jupyter/labconfig/default_setting_overrides.json

RUN ./miniconda3_eval.bash python -m pip install faiss-cpu
RUN ./miniconda3_eval.bash python -m pip install jupyter-ai
RUN ./miniconda3_eval.bash python -m pip install gpt4all
RUN ./miniconda3_eval.bash python -m pip install pypdf

# By default, serve jupyter lab at container startup 

SHELL ["/bin/bash", "-i", "-c"]
CMD jupyter lab --port=8888 --ip=0.0.0.0 --no-browser --allow-root

