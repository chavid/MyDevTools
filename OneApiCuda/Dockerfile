FROM intel/oneapi-basekit

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# So to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# Preparation CUDA
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
RUN mv -f cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda-repo-ubuntu2204-12-2-local_12.2.0-535.54.03-1_amd64.deb
RUN dpkg -i cuda-repo-ubuntu2204-12-2-local_12.2.0-535.54.03-1_amd64.deb
RUN cp /var/cuda-repo-ubuntu2204-12-2-local/cuda-*-keyring.gpg /usr/share/keyrings/

# Installations apt-get, DEBUT
RUN apt-get update \
&& apt-get install -y cuda

# Installations apt-get, FIN
RUN rm -rf /var/lib/apt/lists/*

# Installation plugin Codeplay
COPY oneapi-for-nvidia-gpus-2023.1.0-cuda-12.0-linux.sh .
RUN sh oneapi-for-nvidia-gpus-2023.1.0-cuda-12.0-linux.sh

