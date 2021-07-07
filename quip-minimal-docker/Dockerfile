################################################################################
# build image
################################################################################
# this uses conda to build the python environment and then saves it
# for use in the runtime image
# -> compilers and conda not needed in the runtime image
# -> size of image is smaller
FROM continuumio/miniconda3 AS build
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# simple utilities
RUN apt-get -y update \
 && apt-get upgrade -y \
 && apt-get install -y \
        build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN conda create --name to-pack \
        python \
        jupyter \
        numpy \
        scipy \
        scikit-learn\
        matplotlib \
        pyamg \
#        scikit-build\
#        sphinx \
#        sphinx-rtd-theme \
#        torch\
#        torchani\
        numpydoc \
        RISE \
        pandas \
        click

RUN conda install -c conda-forge -n to-pack \
#        imolecule \
        nglview \
        nbsphinx \
        spglib \
        phonopy \
        xtb-python \
        ase

RUN /opt/conda/envs/to-pack/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && /opt/conda/envs/to-pack/bin/jupyter nbextension enable --py --sys-prefix nglview \
 && /opt/conda/envs/to-pack/bin/jupyter-nbextension install rise --py --sys-prefix \
 && /opt/conda/envs/to-pack/bin/jupyter-nbextension enable rise --py --sys-prefix

# PIP only packages
#   - conda has a hard time installing rdkit for some reason
RUN /opt/conda/envs/to-pack/bin/pip install quippy-ase imolecule rdkit-pypi

# No need to keep source here
RUN git clone https://github.com/libAtoms/matscipy.git /opt/matscipy \
 && cd /opt/matscipy \
 && /opt/conda/envs/to-pack/bin/pip install --no-cache-dir . \
 && rm -rvf /opt/matscipy

# pack up this conda env for the main image
RUN conda install -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n to-pack -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

################################################################################
# Runtime image
################################################################################
# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster AS runtime

# Copy /venv from the previous stage & add to path
COPY --from=build /venv /venv
ENV PATH "$PATH:/venv/bin"

################################################################################
# simple utilities
################################################################################
RUN apt-get -y update \
 && apt-get upgrade -y \
 && apt-get install -y \
        # Useful tools
        curl \
        wget \
        git \
        vim \
        emacs-nox \
        less \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

################################################################################
# Source files
################################################################################
# copies the version of QUIP pinned in this repo
#COPY QUIP /opt/quip

# matscipy source
RUN git clone https://github.com/libAtoms/matscipy.git /opt/matscipy

################################################################################
# Entrypoint
################################################################################

WORKDIR /root/

# Set bash instead of sh as defualt terminal in Jupyter
SHELL ["/bin/bash", "-c"]

CMD source /venv/bin/activate && bash -c exit && jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
EXPOSE 8899
