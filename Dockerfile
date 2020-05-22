FROM ubuntu:latest

ENV TERM=xterm

RUN apt-get update && \
  apt-get install -yqq \
  build-essential \
  git

RUN apt-get install -yqq curl vim htop

RUN mkdir -p /app/bashmatic
COPY . /app/bashmatic
WORKDIR /app/bashmatic
ENV BASHMATIC_HOME /app/bashmatic
RUN cat /app/bashmatic/.bash_profile >> ${HOME}/.profile
RUN rm -rf /app/bashmatic/.git

ENTRYPOINT /bin/bash -l

