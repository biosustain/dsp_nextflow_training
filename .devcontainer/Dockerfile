FROM mcr.microsoft.com/devcontainers/base:noble
WORKDIR /home

ARG NEXTFLOW_VERSION=26.10.4

RUN apt update \
    && apt -y install \
        openjdk-21-jre \
        python3-venv \
        tree \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -s -o /usr/local/bin/nextflow \
        https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow-${NEXTFLOW_VERSION}-dist \
    && chmod +x /usr/local/bin/nextflow \
    && ln -s /usr/bin/python3 /usr/bin/python
