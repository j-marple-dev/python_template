FROM ubuntu:bionic

LABEL maintainer="Jongkuk Lim <limjk@jmarple.ai>"
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

ARG	UID=1000
ARG	GID=1000
RUN	groupadd -g $GID -o user && useradd -m -u $UID -g $GID -o -s /bin/bash user

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y sudo dialog apt-utils tzdata
RUN	echo "%sudo	ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && echo "user:user" | chpasswd && adduser user sudo

WORKDIR	/home/user
USER	user

# Install Display dependencies
RUN sudo apt-get update && sudo apt-get install -y libgl1-mesa-dev && sudo apt-get -y install jq

# Install python3.8
RUN sudo apt-get update && sudo apt-get install software-properties-common git -y
RUN sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt-get install python3.8-dev -y
RUN sudo ln -s /usr/bin/pip3 /usr/bin/pip && \
    sudo ln -s /usr/bin/python3.8 /usr/bin/python

# Terminal environment
RUN git clone https://github.com/JeiKeiLim/my_term.git \
    && cd my_term \
    && ./run.sh

# Install vim 8.2 with YCM
RUN sudo apt-get install -y software-properties-common \
    && sudo add-apt-repository ppa:jonathonf/vim \
    && sudo add-apt-repository ppa:ubuntu-toolchain-r/test \
    && sudo apt-get update \
    && sudo apt-get install -y vim g++-8 libstdc++6 cmake wget

# Install cmake 3.21.0 version.
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0-linux-x86_64.tar.gz \
    && tar -xzvf cmake-3.21.0-linux-x86_64.tar.gz \
    && sudo mv /usr/bin/cmake /usr/bin/cmake.old \
    && sudo mv /usr/bin/ctest /usr/bin/ctest.old \
    && sudo mv /usr/bin/cpack /usr/bin/cpack.old \
    && sudo ln -s /home/user/cmake-3.21.0-linux-x86_64/bin/cmake /usr/bin/cmake \
    && sudo ln -s /home/user/root/cmake-3.21.0-linux-x86_64/bin/ctest /usr/bin/ctest \
    && sudo ln -s /home/user/root/cmake-3.21.0-linux-x86_64/bin/cpack /usr/bin/cpack \
    && rm cmake-3.21.0-linux-x86_64.tar.gz

RUN cd /home/user/.vim_runtime/my_plugins \
    && git clone --recursive https://github.com/ycm-core/YouCompleteMe.git \
    && cd YouCompleteMe \
    && CC=gcc-8 CXX=g++-8 python install.py --clangd-completer
