# Thi Dockerfile is provided so that we can eventually build 
# linux support for the bin/setup script.
#
# vim: ft=Dockerfile
# 
# © 2021 Konstantin Gredeskoul, All rights reserved, MIT License.
# 
# docker build . -t bashmatic:latest
# docker run -it bashmatic:latest
#
# Once in the container: 
#    
#    # Run specs in linux:
#    $ specs
#    
#    # Test encryption:
#    $ encrypt word
#    

FROM ruby:3.1.2-slim

RUN apt-get update -y && \
    apt-get install -yqq \
    build-essential \
    git

ENV TERM=xterm-256color \
    BASHMATIC_HOME=/app/bashmatic \
    USER=root \
    HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    TZ=Pacific/Los_Angeles
  
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y && apt-get install -yqq locales
RUN locale-gen en_US.UTF-8

RUN apt-get update -y && apt-get install -yqq \
    silversearcher-ag \
    curl \
    vim \
    htop \
    direnv \
    zsh \
    fish \
    rbenv \
    sudo

RUN apt-get install -yqq \
    python3-pip

ENV SHELL_INIT="${HOME}/.bashrc"

RUN set -e && \
    cd ${HOME} && \
    git clone https://github.com/kigster/bash-it .bash_it && \
    cd .bash_it && \
    ./install.sh -s && \
    sed -i'' -E 's/bobby/powerline-multiline/g' ${SHELL_INIT} && \
    echo 'eval "$(direnv hook bash)"' >>${SHELL_INIT} && \
    gem install sym --no-document >/dev/null

RUN echo 'powerline.prompt.set-right-to ruby go user_info ssh clock' >>${SHELL_INIT} && \
    echo 'export POWERLINE_PROMPT_CHAR="#"' >>${SHELL_INIT}

RUN mkdir -p ${BASHMATIC_HOME}
COPY . ${BASHMATIC_HOME}

WORKDIR ${BASHMATIC_HOME}

RUN cd ${BASHMATIC_HOME} && \
    direnv allow . && \
    pwd -P && \
    ls -al

RUN rm -f ~/.zshrc && \
    /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    touch ${HOME}/.zshrc

RUN sed -i'' -E 's/robbyrussell/agnoster/g' ${HOME}/.zshrc
RUN echo system > .ruby-version

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENTRYPOINT /bin/bash -l

