# hash:sha256:d1a160e665c6db273ff43fa4380ce8bf67646975f7d3dcd09379e4ae301f8bcc
FROM registry.codeocean.com/codeocean/matlab:2016b-ubuntu16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG MLM_LICENSE_FILE

COPY postInstall /
RUN /postInstall
