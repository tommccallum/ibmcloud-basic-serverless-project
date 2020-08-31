# Docker file that is the same version as the toolchain to speed up debugging
FROM ubuntu:xenial
ENV TZ=Europe/London
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean
RUN apt-get -y update
RUN apt-get -y install git curl sudo apt-utils
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
RUN mkdir -p /home/pipeline
WORKDIR "/home/pipeline"
RUN git clone https://github.com/tommccallum/ibmcloud-basic-serverless-project -b angular-update .
RUN ./services/deployment/startup.sh
