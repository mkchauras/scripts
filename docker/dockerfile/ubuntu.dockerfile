# Base image
FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    autoconf \
    automake \
    libtool \
    pkg-config \
    git \
    curl \
    wget \
    vim \
    nano \
    gdb \
    strace \
    ltrace \
    valgrind \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    clang \
    llvm \
    lldb \
    clang-format \
    clang-tidy \
    rustc \
    cargo \
    golang \
    openjdk-21-jdk \
    ca-certificates \
    unzip \
    zip \
    tar \
    xz-utils \
    sudo \
    iputils-ping \
    net-tools \
    dnsutils \
    iproute2 \
    tcpdump \
    tree \
    htop \
    jq \
    file \
    less \
    rsync \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create working directory
WORKDIR /workspace

# Default shell
CMD ["/bin/bash"]
