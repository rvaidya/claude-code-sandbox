# Multi-stage build for shared base layers
# Stage 1: Base image with common tools (shared across all workspaces)
FROM debian:bookworm-slim AS base

# Build arguments
ARG BASE_IMAGE=""

# Install base packages and dependencies for asdf and language builds
RUN apt-get update && apt-get install -y \
    git \
    sudo \
    curl \
    bash \
    wget \
    tar \
    gzip \
    unzip \
    make \
    gcc \
    g++ \
    openssh-client \
    rsync \
    file \
    less \
    tree \
    vim \
    nano \
    jq \
    gosu \
    ca-certificates \
    gnupg \
    lsb-release \
    # Dependencies for asdf and language builds \
    coreutils \
    autoconf \
    automake \
    libtool-bin \
    libncurses-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    liblzma-dev \
    linux-libc-dev \
    build-essential \
    # Additional tools \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Create python symlink for consistency
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# Create node user and group
RUN groupadd -r node -g 1000 && \
    useradd -r -g node -u 1000 -m -d /home/node -s /bin/bash node

# Install asdf for the node user
RUN gosu 1000:1000 sh -c "git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1"

# Set up asdf in bashrc for the node user
RUN gosu 1000:1000 sh -c "echo 'source \$HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo 'source \$HOME/.asdf/completions/asdf.bash' >> ~/.bashrc"

# Note: Base image only contains asdf setup, tools are installed in workspace stage

# Install uv for the node user
RUN gosu 1000:1000 sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"

# Add uv to PATH in bashrc for the node user
RUN gosu 1000:1000 sh -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"

# Add node user to docker group for Docker socket access
RUN addgroup docker || true && adduser node docker

# Create a wrapper script that installs claude-code on first run and sources asdf
RUN echo '#!/bin/bash' > /usr/local/bin/claude-wrapper && \
    echo 'source ~/.asdf/asdf.sh 2>/dev/null || true' >> /usr/local/bin/claude-wrapper && \
    echo '' >> /usr/local/bin/claude-wrapper && \
    echo '# Check if Node.js is available' >> /usr/local/bin/claude-wrapper && \
    echo 'if ! command -v node >/dev/null 2>&1; then' >> /usr/local/bin/claude-wrapper && \
    echo '    echo "Error: Node.js is not installed. Please install Node.js first."' >> /usr/local/bin/claude-wrapper && \
    echo '    exit 1' >> /usr/local/bin/claude-wrapper && \
    echo 'fi' >> /usr/local/bin/claude-wrapper && \
    echo '' >> /usr/local/bin/claude-wrapper && \
    echo '# Install claude-code if not already installed for current Node.js version' >> /usr/local/bin/claude-wrapper && \
    echo 'CLAUDE_PATH=$(npm root -g 2>/dev/null)/@anthropic-ai/claude-code/cli.js' >> /usr/local/bin/claude-wrapper && \
    echo 'if [[ ! -f "$CLAUDE_PATH" ]]; then' >> /usr/local/bin/claude-wrapper && \
    echo '    echo "Installing Claude Code for current Node.js version..."' >> /usr/local/bin/claude-wrapper && \
    echo '    npm install -g @anthropic-ai/claude-code' >> /usr/local/bin/claude-wrapper && \
    echo '    asdf reshim nodejs' >> /usr/local/bin/claude-wrapper && \
    echo 'fi' >> /usr/local/bin/claude-wrapper && \
    echo '' >> /usr/local/bin/claude-wrapper && \
    echo 'exec node --no-warnings --enable-source-maps "$CLAUDE_PATH" "$@"' >> /usr/local/bin/claude-wrapper && \
    chmod +x /usr/local/bin/claude-wrapper

# Create a script to setup user and run commands
RUN echo '#!/bin/bash' > /usr/local/bin/setup-and-run && \
    echo 'USER_ID=${HOST_USER_ID:-1000}' >> /usr/local/bin/setup-and-run && \
    echo 'GROUP_ID=${HOST_GROUP_ID:-1000}' >> /usr/local/bin/setup-and-run && \
    echo 'USERNAME=${HOST_USERNAME:-node}' >> /usr/local/bin/setup-and-run && \
    echo 'if [ "$USER_ID" != "1000" ] || [ "$USERNAME" != "node" ]; then' >> /usr/local/bin/setup-and-run && \
    echo '  groupadd -g "$GROUP_ID" "$USERNAME" 2>/dev/null || true' >> /usr/local/bin/setup-and-run && \
    echo '  useradd -u "$USER_ID" -g "$GROUP_ID" -d "/home/$USERNAME" -m "$USERNAME" 2>/dev/null || true' >> /usr/local/bin/setup-and-run && \
    echo 'fi' >> /usr/local/bin/setup-and-run && \
    echo '# Run the command as the specified user' >> /usr/local/bin/setup-and-run && \
    echo 'exec gosu "$USER_ID:$GROUP_ID" bash -c "$*"' >> /usr/local/bin/setup-and-run && \
    chmod +x /usr/local/bin/setup-and-run

# Stage 2: Workspace-specific image with tools (inherits from base)
FROM base AS workspace

# Build argument for tools to install
ARG INSTALL_TOOLS=""

# Install asdf plugins and tools based on INSTALL_TOOLS argument
RUN if [ -n "$INSTALL_TOOLS" ]; then \
        echo "Installing tools: $INSTALL_TOOLS" && \
        gosu 1000:1000 bash -c " \
            source ~/.asdf/asdf.sh && \
            export TOOLS='$INSTALL_TOOLS' && \
            IFS=',' read -ra TOOL_ARRAY <<< \"\$TOOLS\" && \
            for tool in \"\${TOOL_ARRAY[@]}\"; do \
                if [[ \"\$tool\" == *@* ]]; then \
                    plugin=\"\${tool%@*}\" && \
                    version=\"\${tool#*@}\" && \
                    echo \"Installing plugin: \$plugin version \$version\" && \
                    asdf plugin add \"\$plugin\" 2>/dev/null || true && \
                    asdf install \"\$plugin\" \"\$version\" && \
                    asdf global \"\$plugin\" \"\$version\"; \
                else \
                    echo \"Installing plugin: \$tool (latest)\" && \
                    asdf plugin add \"\$tool\" 2>/dev/null || true; \
                fi; \
            done \
        "; \
    fi

WORKDIR /workspace

ENV PATH="/home/node/.local/bin:/usr/local/bin:$PATH"

CMD ["setup-and-run"]