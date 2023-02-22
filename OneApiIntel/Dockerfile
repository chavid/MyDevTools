FROM intel/oneapi-basekit:2022.3.1-devel-ubuntu20.04

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# So to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# Installations apt-get, DEBUT
RUN apt-get update \
&& apt-get install -y apt-utils

# Installations apt-get, pour GRAY-SCOTT
RUN apt-get install -y libhdf5-dev \
&& apt-get install -y libpng-dev

# Installation CUDA 11 (https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network)
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
&& dpkg -i cuda-keyring_1.0-1_all.deb \
&& apt-get update \
&& apt-get -y install cuda

# Installations apt-get, FIN
RUN rm -rf /var/lib/apt/lists/*

# timezone
ENV TZ=Europe/Paris

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
