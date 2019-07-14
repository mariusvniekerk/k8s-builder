# conda-forge/k8s-builder

FROM ubuntu:18.04

RUN apt-get update

RUN apt-get install -y git python3.6 apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

RUN apt-get update
RUN apt-get install --yes docker-ce docker-ce-cli containerd.io