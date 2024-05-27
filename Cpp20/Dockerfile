FROM gcc:13.2.0

# Ensure use of bash
SHELL ["/bin/bash","-c"]

# timezone
ENV TZ=Europe/Paris

# So to avoid debconf interactive questions
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ARG DEBIAN_FRONTEND=noninteractive

# Installations apt-get, DEBUT
RUN apt-get update \
&& apt-get upgrade -y \
&& apt-get install -y apt-utils

# Installations apt-get, UTILITAIRES
RUN apt-get install -y time \
&& apt-get install -y bc \
&& apt-get install -y vim \
&& apt-get install -y wget \
&& apt-get install -y git \
&& apt-get install -y emacs-nox \
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

# Installation TBB & Boost
RUN apt-get install -y libtbb-dev  \
&& apt-get install -y libboost-date-time-dev  \
&& apt-get install -y libboost-program-options-dev

# Installations apt-get, PYTHON
RUN apt-get install -y python3 \
&& apt-get install -y python3-dev \
&& apt-get install -y python3-pip \
&& apt-get install -y python3-tk
RUN apt-get install -y python-is-python3
RUN apt-get install -y pipx

# For the conversion of notebooks to pdf via latex
RUN apt-get install -y pandoc
RUN apt-get install -y texlive
#&& apt-get install -y texlive-xetex \
#&& apt-get install -y texlive-fonts-recommended \
#&& apt-get install -y texlive-generic-extra \
#&& apt-get install -y texlive-generic-recommended

# For the conversion of notebooks to pdf via html (betatim)
RUN apt-get install -y libx11-xcb1 \
&& apt-get install -y libxtst6 \
&& apt-get install -y libxrandr2 \
&& apt-get install -y libasound2 \
&& apt-get install -y libpangocairo-1.0-0 \
&& apt-get install -y libatk1.0-0 \
&& apt-get install -y libatk-bridge2.0-0 \
&& apt-get install -y libgtk-3-0 \
&& apt-get install -y libnss3 \
&& apt-get install -y libxss1

# Installations apt-get, FIN
RUN rm -rf /var/lib/apt/lists/*

# Maqao
RUN mkdir -p /opt &&  cd /opt && \
    wget https://www.maqao.org/maqao_archive/maqao.x86_64.2.18.0.tar.xz && \
    tar xvf maqao.x86_64.2.18.0.tar.xz && \
    rm -f maqao.x86_64.2.18.0.tar.xz

# Hyperfine
COPY hyperfine_1.16.1_amd64.deb .
RUN dpkg -i hyperfine_1.16.1_amd64.deb

# EVE
RUN git clone -b main https://github.com/jfalcou/eve.git
RUN cd eve \
&& mkdir build && cd build \
&& cmake .. -G Ninja \
&& ninja install \
&& ninja doxygen
 
# fmtlib/fmt
RUN git clone https://github.com/fmtlib/fmt.git
RUN cd fmt \
&& mkdir build && cd build \
&& cmake -DBUILD_SHARED_LIBS=ON -DFMT_TEST=OFF .. \
&& make install

# libcoro
RUN git clone --recurse-submodules https://github.com/jbaldwin/libcoro.git
RUN cd libcoro \
&& mkdir Release && cd Release \
&& cmake -DCMAKE_BUILD_TYPE=Release -DLIBCORO_BUILD_TESTS=OFF -DLIBCORO_BUILD_EXAMPLES=OFF .. \
&& cmake --build . \
&& cp -r ../include/coro /usr/local/include \
&& cp -f libcoro.a /usr/local/lib

# Eigen
COPY eigen-3.4.0.tar.gz .
RUN tar -xvf eigen-3.4.0.tar.gz
RUN cd eigen-3.4.0 \
&& mkdir -p build \
&& cd build \
&& cmake .. \
&& make install \
&& cd ../.. \
&& rm -rf eigen-3.4.0.tar.gz \
&& rm -rf eigen-3.4.0

# CADNA
COPY cadna_c-3.1.11.tar.gz .
RUN tar -xvf cadna_c-3.1.11.tar.gz
RUN cd cadna_c-3.1.11 \
&& ./configure \
&& make install \
&& cd .. \
&& rm -rf cadna_c-3.1.11.tar.gz \
&& rm -rf cadna_c-3.1.11

# group
ARG GROUP_ID=1000
RUN addgroup --gid ${GROUP_ID} dev

# user
ARG USER_ID=1000
RUN adduser --shell /bin/bash --uid ${USER_ID} --gid ${GROUP_ID} --disabled-password dev
USER dev

# Installations pipx
RUN python -m pipx ensurepath
RUN python -m pipx install conan
# pip complement for nb=>pdf via html
#RUN python -m pipx notebook-as-pdf
#RUN pyppeteer-install

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
