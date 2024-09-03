FROM ubuntu:22.04 AS base

RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    build-essential \
    clang \
    cmake \
    git \
    ca-certificates \
    wget \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 tutorial
RUN useradd --create-home --shell /bin/bash -u 1000 -g 1000 tutorial
RUN mkdir -p /build && chown 1000:1000 /build
USER 1000

###################################
FROM base AS sv2vbuild

RUN cd /build && \
    wget "https://github.com/zachjs/sv2v/releases/download/v0.0.12/sv2v-Linux.zip" && \
    7z x sv2v-Linux.zip

###################################
FROM base AS cocoverif

RUN cd /build && \
    wget "https://seafile.iaik.tugraz.at/seafhttp/files/4615000b-65a7-47e5-a1c0-27bd68bdba38/coco-verif-preview.zip"

###################################
FROM base AS yosys

USER 0
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN cd /build && \
    git clone -b yosys-0.43 https://github.com/YosysHQ/yosys.git && \
    cd yosys && \
    git submodule update --init && \
    make -j6 && \
    make install
USER 1000

###################################
FROM yosys AS verilator

USER 0
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    git help2man perl python3 make autoconf g++ flex bison ccache \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev zlib1g zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN cd /build && \
    git clone --depth 1 -b v5.026 https://github.com/verilator/verilator.git && \
    unset VERILATOR_ROOT && \
    cd verilator && \ 
    autoconf && \ 
    ./configure && \ 
    make -j6 && \
    make install
USER 1000

###################################
FROM verilator AS final

USER 0
RUN mkdir "/opt/coco-verif-preview" && chown tutorial "/opt/coco-verif-preview"
COPY --from=sv2vbuild /build/sv2v-Linux/sv2v /bin
COPY --from=cocoverif /build/coco-verif-preview.zip /opt 
USER 1000
WORKDIR /home/tutorial
