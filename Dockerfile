FROM node:20-bookworm

RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    ca-certificates \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install uv globally
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Install Claude Code globally
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && install -m 0755 /root/.local/bin/claude /usr/local/bin/claude

# Dedicated non-root user for Claude
RUN useradd -m -s /bin/bash claude \
    && mkdir -p /home/claude/.claude \
    && chown -R claude:claude /home/claude

WORKDIR /workspace
USER claude

CMD ["/bin/bash"]