# the base image is ubuntu
FROM ubuntu:18.04

# create basic working environment
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
 && echo UTC > /etc/timezone \
 && apt-get update \
 && apt-get -y --no-install-recommends install \
    make \
    git \
    ca-certificates \
    gfortran-8 \
    python3 \
    python3-numpy \
    python3-scipy \
    python3-netcdf4 \
    python3-six \
    python3-matplotlib \
    python3-rasterio \
    python3-requests \
 && rm -rf /var/lib/apt/lists/* \
 && rm /usr/bin/python \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && useradd -ms /bin/bash landspill

# change user to landspill
USER landspill
WORKDIR /home/landspill

# set up necessary environment variables
ENV PYTHON=python3 \
    FC=gfortran-8 \
    CLAW=/home/landspill/clawpack \
    PYTHONPATH=/home/landspill/clawpack \
    MPLBACKEND=agg

# clone clawpack and its submodules
RUN git clone --branch v5.5.0 https://github.com/clawpack/clawpack.git \
 && cd clawpack \
 && $PYTHON setup.py git-dev \
 && cd geoclaw \
 && git remote add barbagroup https://github.com/barbagroup/geoclaw.git \
 && git fetch barbagroup pull/17/head:pr-17 \
 && git checkout pr-17

# clone geoclaw-landspill-cases
RUN cd /home/landspill \
 && git clone https://github.com/barbagroup/geoclaw-landspill-cases.git \
 && cd geoclaw-landspill-cases \
 && $PYTHON setup.py

# default command
CMD ["/bin/bash"]
