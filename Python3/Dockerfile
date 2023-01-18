
# Version 0
FROM continuumio/anaconda3:2022.10

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# timezone
ENV TZ=Europe/Paris

# conda installations
RUN conda install -c conda-forge pygit2
RUN conda install -c conda-forge rise
RUN conda install -c conda-forge nbdime

# aptget : so to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# apt-get begin
RUN apt-get update \
&& apt-get install -y apt-utils

# other apt installations ?
RUN apt-get install -y time  \
&& apt-get install -y bc \
&& apt-get install -y iputils-ping

# Fin des installations apt-get
RUN rm -rf /var/lib/apt/lists/*

# update libraries cache
RUN ldconfig

# démarre un terminal 
CMD bash
