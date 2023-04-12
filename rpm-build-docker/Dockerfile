FROM debian:bullseye-slim
WORKDIR /usr/src/sdw

#npm has some prompts on installation. let's suppres them
ARG DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update
RUN apt-get install -y git gpg
RUN apt-get --yes install binutils
RUN apt-get install --no-install-recommends -y \
            		python3 python3-venv python3-setuptools file python3-rpm \
            		rpm rpm-common diffoscope reprotest disorderfs faketime xvfb

