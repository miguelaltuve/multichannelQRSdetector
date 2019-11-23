# hash:sha256:0a2ace6978bfc11f52d49935bc4c415c4ca0604f9134ac6a1da519aaf4402e9e
FROM registry.codeocean.com/codeocean/matlab:2016b-cuda8.0.61-cudnn6.0.21-ubuntu16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG MLM_LICENSE_FILE

COPY postInstall /
RUN /postInstall
