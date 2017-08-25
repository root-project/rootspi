FROM rootproject/root-ubuntu16-base

ADD build.sh /

ARG uid

RUN useradd --create-home --home-dir /home/builder/ --uid ${uid} --groups sudo builder && \
    passwd --delete builder

USER builder
ENV HOME /home/builder
