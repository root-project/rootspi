FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y install \
            ccache
            cmake
            g++
            gcc
            git
            libgsl0-dev
            libmysqlclient-dev
            libodbc1
            libpythia8-dev
            libpq-dev
            libsqlite3-dev
            libx11-dev
            libxext-dev
            libxft-dev
            libxml2-dev
            libxpm-dev
            locales
            lsb-release
            make
            python
            python-dev
            sudo \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -f UTF-8 en_US.UTF-8
