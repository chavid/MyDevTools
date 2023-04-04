FROM datainpoint/xeus-cling-notebook:0507bda978f8

SHELL ["/bin/bash","-c"]

# conda installations
RUN conda install -y -c conda-forge rise
RUN conda install -y -c conda-forge cmake

# timezone
ENV TZ=Europe/Paris

# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
