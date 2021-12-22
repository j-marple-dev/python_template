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
RUN sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt-get install python3.8 python3.8-dev python3-distutils curl -y
RUN sudo ln -s /usr/bin/pip3 /usr/bin/pip && \
    sudo ln -s /usr/bin/python3.8 /usr/bin/python
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py --force-reinstall && python -m pip install --upgrade pip && rm get-pip.py

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

# Fix error messages with vim plugins
RUN cd /home/user/.vim_runtime/sources_non_forked && rm -rf tlib vim-fugitive && git clone https://github.com/tomtom/tlib_vim.git tlib && git clone https://github.com/tpope/vim-fugitive.git 

COPY ./requirements.txt ./
COPY ./requirements-dev.txt ./
RUN python -m pip install -r requirements.txt && python -m pip install -r requirements-dev.txt
RUN rm requirements.txt requirements-dev.txt

# Add PATH
RUN echo "export PATH=/home/user/.local/bin:\$PATH" >> /home/user/.bashrc
RUN echo "export LC_ALL=C.UTF-8 && export LANG=C.UTF-8" >> /home/user/.bashrc

# Install zsh with powerlevel10k theme
ARG USE_ZSH=true

RUN sudo apt-get install -y zsh && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
COPY res/.zshrc res/.p10k.zsh /home/user/
RUN sudo chown user:user .zshrc .p10k.zsh

RUN if [ "$USE_ZSH" = "true" ]; then \
    sudo chsh -s $(which zsh) $(whoami) && \
    echo "\n# Custom settings" >> /home/user/.zshrc && \
    echo "export PATH=/home/user/.local/bin:\$PATH" >> /home/user/.zshrc && \
    echo "export LC_ALL=C.UTF-8 && export LANG=C.UTF-8" >> /home/user/.zshrc; \
    fi

