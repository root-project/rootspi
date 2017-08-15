FROM rootproject/root-ubuntu16-base

ADD build.sh /
ENV LD_LIBRARY_PATH="/usr/local/lib/root"

ARG uid
ARG gid

RUN mkdir -p /home/sftnight && \
    echo "sftnight:x:${uid}:${gid}:sftnight,,,:/home/sftnight:/bin/bash" >> /etc/passwd && \
    echo "sftnight:x:${uid}:" >> /etc/group && \
    echo "sftnight ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sftnight && \
    chmod 0440 /etc/sudoers.d/sftnight && \
    chown ${uid}:${gid} -R /home/sftnight

USER sftnight
ENV HOME /home/sftnight
