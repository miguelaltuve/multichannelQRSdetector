# hash:sha256:7c52e26fb43dfeb0ccdf085b5b2b969076c9a9cbf146e63e1ba824db1c82b15e
FROM registry.codeocean.com/codeocean/matlab:2016b-ubuntu16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG MLM_LICENSE_FILE

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-pip=8.1.1-2ubuntu0.4 \
        python3-setuptools=20.7.0-1 \
        python3-wheel=0.29.0-1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U --no-cache-dir \
    jupyterlab==1.2.3

COPY postInstall /
RUN /postInstall
