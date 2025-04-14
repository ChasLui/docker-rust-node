# 第一阶段：基础构建环境
FROM node:22-bookworm-slim AS base
# 安装 Rust openssl 等基础依赖
RUN apt-get update && \
    apt-get install -y curl build-essential openssl libssl3 pkg-config && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 第二阶段：后端构建
FROM base AS builder
WORKDIR /build
COPY . .

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"
