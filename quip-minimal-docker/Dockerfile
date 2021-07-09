################################################################################
# Very mimal image with quippy installed
################################################################################
FROM continuumio/miniconda3
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# simple utilities
RUN apt-get -y update \
 && apt-get upgrade -y \
 && apt-get install -y \
        curl \
        wget \
        git \
        vim \
        emacs-nox \
        less \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN conda install -c defaults -c conda-forge \
        jupyter \
        numpy \
        scipy \
        matplotlib \
        nglview \
        spglib \
        xtb-python \
        ase

# PIP only packages
RUN pip install quippy-ase


################################################################################
# Entrypoint
################################################################################

WORKDIR /root/

# Set bash instead of sh as defualt terminal in Jupyter
SHELL ["/bin/bash", "-c"]

CMD bash -c exit && jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
EXPOSE 8899
