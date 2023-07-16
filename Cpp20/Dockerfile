FROM gcc:13.1.0

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
&& apt-get install -y cmake \
&& apt-get install -y git \
&& apt-get install -y x11-apps

# Installations apt-get, C++ Tools
RUN apt-get install -y build-essential  \
&& apt-get install -y cmake  \
&& apt-get install -y ninja-build  \
&& apt-get install -y doxygen  \
&& apt-get install -y cppcheck  \
&& apt-get install -y clang-format  \
&& apt-get install -y libc6-dbg gdb \
&& apt-get install -y binutils graphviz \
&& apt-get install -y valgrind kcachegrind

# Installations apt-get, PYTHON
RUN apt-get install -y python-dev-is-python3

# Installations apt-get, FIN
RUN rm -rf /var/lib/apt/lists/*

# fmtlib/fmt
RUN git clone https://github.com/fmtlib/fmt.git
RUN cd fmt \
&& mkdir build && cd build \
&& cmake -DBUILD_SHARED_LIBS=ON -DFMT_TEST=OFF .. \
&& make install

# libcoro
#RUN git clone --recurse-submodules https://github.com/jbaldwin/libcoro.git
#RUN cd libcoro \
#&& mkdir Release && cd Release \
#&& cmake -DCMAKE_BUILD_TYPE=Release .. \
#&& cmake --build . \
#&& make install

# CADNA
COPY cadna_c-3.1.11.tar.gz .
RUN tar -xvf cadna_c-3.1.11.tar.gz
RUN cd cadna_c-3.1.11 \
&& ./configure \
&& make install \
&& cd .. \
&& rm -rf cadna_c-3.1.11.tar.gz \
&& rm -rf cadna_c-3.1.11

# timezone
ENV TZ=Europe/Paris

# group
ARG GROUP_ID=1000
RUN addgroup --gid ${GROUP_ID} dev

# user
ARG USER_ID=1000
RUN adduser --shell /bin/bash --uid ${USER_ID} --gid ${GROUP_ID} --disabled-password dev
USER dev

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
