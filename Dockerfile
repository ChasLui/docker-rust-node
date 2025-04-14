# 第一阶段：构建环境
FROM node:22-slim AS builder

# 安装 Rust 和构建依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    pkg-config \
    libssl-dev && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-unknown-unknown && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"

# 第二阶段：运行环境
FROM node:22-slim AS runtime

# 只安装运行时必需的包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 从构建阶段复制必要的文件
COPY --from=builder /root/.cargo/bin/cargo /usr/local/bin/cargo
COPY --from=builder /root/.cargo/bin/rustc /usr/local/bin/rustc
COPY --from=builder /root/.rustup /root/.rustup
COPY --from=builder /root/.cargo /root/.cargo

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"

WORKDIR /app
