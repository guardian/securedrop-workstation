FROM fedora:40
WORKDIR /usr/src/sdw

#npm has some prompts on installation. let's suppres them
ARG DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN dnf -y update
RUN dnf install -y git gpg
RUN dnf install -y \
    python3 python3-setuptools python3-rpm \
    rpm diffoscope reprotest faketime  \
    python3-pip python3-wheel python3-devel rpm-sign
RUN python3 --version
RUN git config --global --add safe.directory /src
