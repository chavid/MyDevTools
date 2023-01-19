
# Version 0
FROM continuumio/anaconda3:2022.10

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# timezone
ENV TZ=Europe/Paris

# aptget : so to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# apt-get begin
RUN apt-get update \
&& apt-get install -y apt-utils

# utilities
RUN apt-get install -y time  \
&& apt-get install -y bc \
&& apt-get install -y iputils-ping

# conversion des notebooks en pdf
RUN apt-get install -y texlive-xetex \
&& apt-get install -y wkhtmltopdf \
&& apt-get install -y gcc

# Fin des installations apt-get
RUN rm -rf /var/lib/apt/lists/*

# update libraries cache
RUN ldconfig

# pip installations
#RUN pip install mpi4py
RUN pip install pygit2

# conda installations
RUN conda update -n base -c defaults conda
RUN conda install -c anaconda rise
RUN conda install -c anaconda cffi
RUN conda install -c anaconda cython
#RUN conda install -c conda-forge pygit2
RUN conda install -c conda-forge nbdime
RUN conda install -c conda-forge pdoc3

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
