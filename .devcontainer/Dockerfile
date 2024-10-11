# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Install Java 11 (required for Nextflow)
RUN apt-get update && apt-get install -y \
  openjdk-11-jdk \
  curl \
  gnupg2 \
  lsb-release \
  software-properties-common

# Install Docker dependencies (optional, if not using features)
RUN apt-get update && apt-get install -y \
  docker.io \
  docker-compose

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# Expose Docker socket
RUN groupadd docker && usermod -aG docker $USER
