FROM devcpp20:v12

# Miniconda3 with Python 3.11

RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_24.1.2-0-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN ~/miniconda3/bin/conda init bash

SHELL ["/bin/bash","-i","-c"]

# Pip installations, so to get classical notebooks and operational rise

RUN python -m pip install nbclassic
RUN python -m pip install rise

# Conda installations

RUN conda install -c conda-forge -y jupyterlab
RUN conda install -c conda-forge -y xeus-cling

# By default, serve jupyter lab at container startup 

CMD jupyter lab --port=8888 --ip=0.0.0.0 --no-browser --allow-root

