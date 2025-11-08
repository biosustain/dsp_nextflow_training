FROM mcr.microsoft.com/devcontainers/base:noble
WORKDIR /home

RUN apt update \
    && apt -y install \
        openjdk-21-jre \
        python3-venv \
    && curl -L -s -o /usr/local/bin/nextflow \
        https://github.com/nextflow-io/nextflow/releases/download/v25.04.3/nextflow-25.04.3-dist \
    && chmod +x /usr/local/bin/nextflow \
    && ln -s /usr/bin/python3 /usr/bin/python