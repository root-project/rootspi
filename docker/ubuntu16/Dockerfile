FROM rootproject/root-ubuntu16-base

ADD build.sh /

ARG uid

RUN useradd --create-home --home-dir /home/sftnight/ --uid ${uid} --groups sudo sftnight && \
    passwd --delete sftnight

USER sftnight:sftnight
ENV HOME /home/sftnight
