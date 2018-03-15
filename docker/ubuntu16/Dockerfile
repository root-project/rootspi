FROM rootproject/root-ubuntu16-base

COPY build.sh build.sh

ARG uid

RUN useradd --create-home --home-dir /home/builder/ --uid ${uid} --groups sudo builder && \
    passwd --delete builder

USER builder
ENV HOME /home/builder
ENV PYTHONPATH /usr/local/lib/root
