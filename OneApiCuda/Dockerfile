FROM ubuntu:20.04

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# So to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# Installations apt-get, DEBUT
RUN apt-get update \
&& apt-get install -y apt-utils

# Installations apt-get, UTILITAIRES
RUN apt-get install -y time \
&& apt-get install -y bc \
&& apt-get install -y vim \
&& apt-get install -y wget \
&& apt-get install -y git

# Installations apt-get, LLVM requirements
RUN apt-get install -y build-essential \
&& apt-get install -y cmake \
&& apt-get install -y python3 python-is-python3 \
&& apt-get install -y zlib1g

# Installations apt-get, FIN
RUN rm -rf /var/lib/apt/lists/*

# Installation CUDA 11
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
&& dpkg -i cuda-keyring_1.0-1_all.deb \
&& apt-get update \
&& apt-get -y install cuda

# Compilation llvm en cuda
RUN git clone https://github.com/intel/llvm.git -b sycl \
&& cd llvm && python ./buildbot/configure.py --cuda -t release --cmake-gen "Unix Makefiles" \
&& cd build && make sycl-toolchain -j `nproc` && make install

# timezone
ENV TZ=Europe/Paris

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
