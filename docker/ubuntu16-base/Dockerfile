FROM ubuntu:16.04

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
             sudo make g++ gcc cmake git libx11-dev libxpm-dev libxft-dev libxext-dev python lsb-release locales libxml2-dev python-dev libgsl0-dev ccache \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -f UTF-8 en_US.UTF-8
