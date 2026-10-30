FROM mcr.microsoft.com/devcontainers/base:noble
WORKDIR /home

ARG NEXTFLOW_VERSION=26.10.4
ARG NFCORE_TOOLS_VERSION=4.2.1

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

# nf-core tools, in its own virtual environment
RUN python3 -m venv /opt/nf-core \
    && /opt/nf-core/bin/pip install --no-cache-dir nf-core==${NFCORE_TOOLS_VERSION} \
    && ln -s /opt/nf-core/bin/nf-core /usr/local/bin/nf-core
