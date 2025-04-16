# 第一阶段：基础构建环境
FROM node:22-bookworm-slim AS base
# 安装 Rust openssl 等基础依赖
RUN apt-get update && \
    apt-get install -y curl build-essential openssl libssl3 pkg-config zip unzip libsqlite3-dev git && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    # 使用rustup安装指定组件
    rustup component add cargo clippy rust-docs rust-std rustc rustfmt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 安装yarn4
RUN npm install -g corepack
RUN corepack enable
RUN corepack prepare yarn@stable --activate
RUN npm install -g node-gyp @electron/node-gyp

# 配置 Cargo 使用阿里云镜像源（稀疏索引配置）
RUN mkdir -p /root/.cargo && \
    echo '[source.crates-io]' > /root/.cargo/config && \
    echo 'replace-with = "aliyun"' >> /root/.cargo/config && \
    echo '[source.aliyun]' >> /root/.cargo/config && \
    echo 'registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"' >> /root/.cargo/config

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"
