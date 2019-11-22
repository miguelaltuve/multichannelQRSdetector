# hash:sha256:2586b78db20e2e420bfeb87a199b1ccc0bb6973f523df84ba3feef6ef0d932f1
FROM registry.codeocean.com/codeocean/matlab:2016b-cuda8.0.61-cudnn6.0.21-ubuntu16.04

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
