FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y install \
            ccache \
            cmake \
            davix-dev \
            g++ \
            gcc \
            git \
            libgif-dev \
            libgsl0-dev \
            libjpeg-dev \
            libmysqlclient-dev \
            libodbc1 \
            libpq-dev \
            libsqlite3-dev \
            libpythia8-dev \
            libtbb-dev \
            libtiff-dev \
            libx11-dev \
            libxext-dev \
            libxft-dev \
            libxml2-dev \
            libxpm-dev \
            locales \
            lsb-release \
            make \
            python \
            python-dev \
            sudo \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -f UTF-8 en_US.UTF-8
