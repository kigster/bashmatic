# vim: ft=Dockerfile

FROM ubuntu:latest

RUN apt-get update -y && \
    apt-get install -yqq \
    build-essential \
    git

RUN apt-get install -yqq \
    silversearcher-ag \
    curl \
    vim \
    htop

ENV TERM=xterm-256color \
    BASHMATIC_HOME=/app/bashmatic \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN apt-get install -yqq \
    locales

RUN mkdir -p ${BASHMATIC_HOME}
COPY . ${BASHMATIC_HOME}

ENV USER=root \
    HOME=/root

ENV SHELL_INIT="${HOME}/.bashrc"

RUN set -e && \
    cd ${HOME} && \
    git clone https://github.com/kigster/bash-it .bash_it && \
    cd .bash_it && \
    ./install.sh -s && \
    sed -i'' -E 's/bobby/powerline-multiline/g' ${SHELL_INIT}

RUN cat ${BASHMATIC_HOME}/.bash_profile >>${SHELL_INIT} && \
    echo 'powerline.prompt.set-right-to ruby go user_info ssh clock' >>${SHELL_INIT} && \
    echo 'export POWERLINE_PROMPT_CHAR="#"' >>${SHELL_INIT} 

WORKDIR ${BASHMATIC_HOME}

ENTRYPOINT /bin/bash -l
