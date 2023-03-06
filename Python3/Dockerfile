
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

# group
ARG GROUP_ID=1000
RUN addgroup --gid ${GROUP_ID} dev

# user
ARG USER_ID=1000
RUN adduser --shell /bin/bash --uid ${USER_ID} --gid ${GROUP_ID} --disabled-password dev
USER dev

# installations pip
#RUN pip install --user mpi4py
RUN pip install --user pygit2
RUN pip install --user rise
RUN pip install --user cffi
RUN pip install --user cython
RUN pip install --user nbdime
RUN pip install --user pdoc3

# poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
