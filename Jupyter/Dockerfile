
# Version 1.0.0
FROM quay.io/jupyter/scipy-notebook

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# timezone
ENV TZ=Europe/Paris

# aptget : so to avoid debconf interactive questions
USER root
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

# for mpi4py
RUN apt-get install -y openmpi-bin libopenmpi-dev

# Fin des installations apt-get
RUN rm -rf /var/lib/apt/lists/*

# update libraries cache
RUN ldconfig

# installations pip
USER ${NB_UID}
RUN python -m pip install --user jupyterlab_rise
RUN python -m pip install --user cffi
RUN python -m pip install --user cython
RUN python -m pip install --user nbdime
RUN python -m pip install --user pdoc3
RUN python -m pip install --user pytest
RUN python -m pip install --user metakernel
RUN python -m pip install --user mpi4py
RUN python -m pip install --user rise

# poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

