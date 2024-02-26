FROM ubuntu:jammy

LABEL maintainer="Jongkuk Lim <limjk@jmarple.ai>, Haneol Kim <hekim@jmarple.ai>"
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

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN sudo apt-get update && sudo apt-get -y install wget curl git
RUN curl -s https://raw.githubusercontent.com/JeiKeiLim/my_term/main/run.sh | /bin/bash

# install zsh & set theme powerlevel10k
RUN sudo apt-get update && sudo apt-get install -y zsh && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN echo "\n# Custom settings" >> /home/user/.zshrc && \
    echo "export PATH=/home/user/.local/bin:$PATH" >> /home/user/.zshrc && \
    echo "export LC_ALL=C.UTF-8 && export LANG=C.UTF-8" >> /home/user/.zshrc && \
    sed '11 c\ZSH_THEME=powerlevel10k/powerlevel10k' ~/.zshrc  > tmp.txt && mv tmp.txt ~/.zshrc && \
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc
RUN sudo chsh -s $(which zsh) $(whoami)

# Install python3
RUN sudo apt-get update && sudo apt-get install software-properties-common git -y
RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt-get install -y python3-pip python3-dev
RUN sudo ln -s /usr/bin/python3 /usr/bin/python

# Install cmake 3.21.0 version.
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0-linux-x86_64.tar.gz \
    && tar -xzvf cmake-3.21.0-linux-x86_64.tar.gz \
    && sudo ln -s /home/user/cmake-3.21.0-linux-x86_64/bin/cmake /usr/bin/cmake \
    && sudo ln -s /home/user/root/cmake-3.21.0-linux-x86_64/bin/ctest /usr/bin/ctest \
    && sudo ln -s /home/user/root/cmake-3.21.0-linux-x86_64/bin/cpack /usr/bin/cpack \
    && rm cmake-3.21.0-linux-x86_64.tar.gz

COPY ./requirements.txt ./
COPY ./requirements-dev.txt ./
RUN python -m pip install -r requirements.txt && python -m pip install -r requirements-dev.txt
RUN rm requirements.txt requirements-dev.txt

# Add PATH
RUN echo "export PATH=/home/user/.local/bin:\$PATH" >> /home/user/.bashrc
RUN echo "export LC_ALL=C.UTF-8 && export LANG=C.UTF-8" >> /home/user/.bashrc

# Place your environment here
