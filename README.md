# Claude Code Sandbox

A sandboxed Docker-based wrapper for running [Claude Code](https://github.com/anthropics/claude-code) CLI in an isolated environment with `--dangerously-skip-permissions` enabled **safely**.

**🛠️ Built on [asdf](https://asdf-vm.com/)** - Install any programming language, runtime, or tool (500+ available) directly in your development container.

## ⚠️ Why This Wrapper Exists

Claude Code's `--dangerously-skip-permissions` flag can be incredibly powerful for development workflows, but as the name suggests, it can be dangerous when run directly on your system. There are horror stories on Reddit and elsewhere of users accidentally damaging their systems.

**This wrapper solves that problem by:**
- Running Claude Code in a completely isolated Docker container
- Enabling `--dangerously-skip-permissions` by default in a safe sandbox
- Protecting your host system while still allowing full development capabilities
- Preserving access to your project files and development configurations

## 🚀 Quick Start - Tool Installation

Install any development tools you need using [asdf plugins](https://github.com/asdf-vm/asdf-plugins):

```bash
# Install specific language versions
./claude-code-sandbox --build --install='python@3.12.8,java@adoptopenjdk-17.0.2+8,maven@3.9.6'

# Install multiple tools with versions
./claude-code-sandbox --build --install='golang@1.21.5,nodejs@20.11.0,terraform@1.5.7'

# Use .tool-versions file (asdf standard)
echo "python 3.12.8
nodejs 20.11.0
java adoptopenjdk-17.0.2+8
maven 3.9.6" > .tool-versions

./claude-code-sandbox  # Auto-detects and installs from .tool-versions

# Test your tools
./claude-code-sandbox -n "python --version && java -version && mvn --version"
```

## Features

- 🛠️ **500+ Development Tools**: Install any language or tool via [asdf plugins](https://github.com/asdf-vm/asdf-plugins) (Python, Java, Node.js, Go, Rust, Maven, Terraform, etc.)
- 📄 **.tool-versions Support**: Drop in a [`.tool-versions`](https://asdf-vm.com/manage/configuration.html#tool-versions) file and tools install automatically
- 🐳 **Dockerized Environment**: Runs Claude Code in an isolated Debian slim container
- 🏠 **Workspace-Specific Images**: Each workspace gets its own Docker image for complete tool isolation
- ⚡ **Incremental Builds**: Smart caching only rebuilds when tools or configuration change
- 🚀 **Shared Base Layers**: Efficient Docker layer sharing reduces disk usage across workspaces
- 🔧 **Configuration Mounting**: Automatically detects and mounts common development configurations
- 🔧 **Auto-completion**: Bash and Zsh completion for commands and tool names
- 🛡️ **Security**: Sandboxed execution prevents potential system modifications
- 🔄 **Live Updates**: Your current working directory is mounted for real-time file access

## Prerequisites

- Docker installed and running
- Bash shell (Linux/macOS/WSL)

## Installation

### Method 1: Symlink to PATH (Recommended)

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd claudecode
   ```

2. Make the script executable:
   ```bash
   chmod +x claude-code-sandbox
   ```

3. Create a symlink in a directory that's in your PATH:
   ```bash
   # For system-wide installation (requires sudo)
   sudo ln -sf "$(pwd)/claude-code-sandbox" /usr/local/bin/claude-code-sandbox
   
   # OR for user-only installation
   mkdir -p ~/.local/bin
   ln -sf "$(pwd)/claude-code-sandbox" ~/.local/bin/claude-code-sandbox
   
   # Make sure ~/.local/bin is in your PATH (add to ~/.bashrc or ~/.zshrc if needed)
   export PATH="$HOME/.local/bin:$PATH"
   ```

4. Verify installation:
   ```bash
   claude-code-sandbox --help
   ```

### Method 2: Direct Usage

1. Make the script executable:
   ```bash
   chmod +x claude-code-sandbox
   ```

2. Run directly from the project directory:
   ```bash
   ./claude-code-sandbox [options]
   ```

## Usage

### First Run

On first execution, the Docker image will be automatically built:

```bash
claude-code-sandbox
```

### Tool Installation (asdf-based)

**Install any development tools you need using the `--install` flag:**

```bash
# Install specific language versions
claude-code-sandbox --build --install='python@3.12.8,java@adoptopenjdk-17.0.2+8'

# Install build tools and DevOps tools
claude-code-sandbox --build --install='maven@3.9.6,terraform@1.5.7,kubectl@1.28.0'

# Install the latest versions (no @ symbol)
claude-code-sandbox --build --install='golang,rust,nodejs'

# Test installed tools
claude-code-sandbox -n "python --version && java -version && mvn --version"
```

**Or use a `.tool-versions` file (recommended for projects):**

```bash
# Create .tool-versions file
cat > .tool-versions << EOF
python 3.12.8
nodejs 20.11.0
java adoptopenjdk-17.0.2+8
maven 3.9.6
terraform 1.5.7
EOF

# Auto-install from .tool-versions (no --build needed)
claude-code-sandbox

# Tools are now available in both shell and Claude Code
claude-code-sandbox --shell  # Interactive development
claude-code-sandbox          # Claude Code with all tools
```

**Available Tools:** Any [asdf plugin](https://github.com/asdf-vm/asdf-plugins) (500+ tools including Python, Java, Node.js, Go, Rust, Maven, Gradle, Terraform, kubectl, Docker Compose, and more).

### Basic Commands

```bash
# Start Claude Code in current directory
claude-code-sandbox

# Build/rebuild the Docker image (useful for updates)
claude-code-sandbox --build
claude-code-sandbox -b    # Short form

# Enter interactive shell instead of Claude Code
claude-code-sandbox --shell
claude-code-sandbox -s    # Short form

# Run non-interactive commands (useful for testing)
claude-code-sandbox --non-interactive "command to run"
claude-code-sandbox -n "command to run"    # Short form

# Enable Docker access inside container (by mounting docker socket)
claude-code-sandbox --docker
claude-code-sandbox -d    # Short form

# Combine flags (build and then enter shell)
claude-code-sandbox -bs
claude-code-sandbox --build --shell

# Pass any Claude Code arguments
claude-code-sandbox --model claude-3-5-sonnet-20241022

# Get help
claude-code-sandbox --help
```

### Auto-completion

Enable intelligent tab completion for commands and tool names:

**Bash:**
```bash
# One-time setup (add to ~/.bashrc for persistence)
source /path/to/claude-code-sandbox/completions/claude-code-sandbox

# Or if you have the script symlinked in PATH:
curl -o ~/.bash_completion.d/claude-code-sandbox \
  https://raw.githubusercontent.com/your-repo/claude-code-sandbox/main/completions/claude-code-sandbox
source ~/.bash_completion.d/claude-code-sandbox
```

**Zsh:**
```bash
# Add to your ~/.zshrc
fpath=(/path/to/claude-code-sandbox/completions $fpath)
autoload -U compinit && compinit
```

**Features:**
- Tab completion for all command flags (`--build`, `--install`, etc.)
- Intelligent tool name completion for `--install=`
- Common tool suggestions (python, nodejs, java, golang, rust, etc.)
- Context-aware completion for comma-separated tool lists
```


### .tool-versions File Support

If your workspace contains a `.tool-versions` file ([asdf standard](https://asdf-vm.com/manage/configuration.html#tool-versions)), the system will automatically install all specified tools when you run `--build` without `--install`:

Example `.tool-versions` file:
```
python 3.12.8
nodejs 20.11.0
java adoptopenjdk-17.0.2+8
terraform 1.5.7
```

**Usage Examples:**
```bash
# Automatic tool installation from .tool-versions
claude-code-sandbox --build

# Test installed tools work correctly
claude-code-sandbox -n "python --version && java -version && terraform --version"

# All tools are automatically available in both interactive and non-interactive modes
claude-code-sandbox --shell  # Interactive shell with all tools in PATH
```

This eliminates the need to specify tools manually for projects that already use [asdf](https://asdf-vm.com/).

### Workspace-Specific Images

Each workspace (directory) automatically gets its own Docker image for complete isolation:

```bash
# First run in a workspace creates a unique image
claude-code-sandbox --build
# Created new workspace image: claude-code-sandbox-ax57fqxm

# Subsequent runs use the same workspace-specific image
claude-code-sandbox
# Using existing workspace image: claude-code-sandbox-ax57fqxm
```

**How it works:**
- A `.claude-code-sandbox` file is created in each workspace with a unique image name
- This ensures different projects don't share Docker images or interfere with each other
- Each workspace can have completely different tool configurations
- You may want to add `.claude-code-sandbox` to your project's `.gitignore` (it's workspace-specific, not meant to be shared)

### Shell Mode & Non-Interactive Testing

**Interactive Shell Mode:**

The `--shell` option launches an interactive bash shell inside the container instead of Claude Code:

```bash
claude-code-sandbox --shell
```

This is particularly useful for:
- **Testing environment issues**: Debug problems with UV, Python, Node.js, or other tools
- **Exploring the container**: See what tools and configurations are available
- **Manual operations**: Run commands directly in the sandboxed environment
- **Troubleshooting**: Investigate PATH issues, missing dependencies, or configuration problems

Once in the shell, you can test tools like:
```bash
uv --version          # Test UV installation
node --version        # Check Node.js
claude-wrapper --help # Test Claude Code wrapper
ls -la /home/node     # Check mounted configurations
```

**Non-Interactive Testing Mode:**

The `--non-interactive` (or `-n`) flag allows you to run commands inside the container without requiring a TTY, perfect for testing and automation:

```bash
# Test Python installation
claude-code-sandbox -n "python --version"

# Test uv installation  
claude-code-sandbox -n "uv --version"

# Test uvx (tool runner)
claude-code-sandbox -n "uvx cowsay --text 'Hello from uvx!'"

# Test virtual environment workflow
claude-code-sandbox -n "uv venv myenv && source myenv/bin/activate && uv pip install requests && python -c 'import requests; print(requests.__version__)'"

# Test basic shell commands
claude-code-sandbox -n "ls -la"

# Test Docker functionality (requires -d flag)
claude-code-sandbox -n -d "docker --version"
claude-code-sandbox -n -d "docker ps"
claude-code-sandbox -n -d "docker run --rm hello-world"
```

### Configuration

The wrapper automatically detects and mounts the following configuration directories:

- **Claude/Anthropic**: `~/.claude`, `~/.config/claude`, `~/.anthropic`, `~/.claude.json`
- **Node.js**: `~/.npm`, `~/.pnpm-store`
- **Python**: `~/.cache` (includes pip cache)
- **Rust**: `~/.cargo`
- **Go**: `~/go`
- **Java**: `~/.gradle`, `~/.m2`
- **Ruby**: `~/.gem`, `~/.bundle`
- **Bun**: `~/.bun`
- **.NET**: `~/.nuget`

## Development Environment

The Docker container includes:

### Base Environment
- **OS**: Debian slim (better compatibility than Alpine)
- **Runtime**: Node.js 22, Python 3 (system-installed)
- **Package Managers**: npm (Node.js), pip3 (Python), uv (modern Python package manager)
- **Development Tools**: git, curl, vim, nano, ripgrep, jq, Docker CLI
- **Build Tools**: make, gcc, g++, autoconf, automake, build-essential
- **Network & File Tools**: SSH client, rsync, tar, gzip, unzip, tree, less

### Dynamic Tool Installation
- **asdf**: [Version manager](https://asdf-vm.com/) for installing any programming language or tool
- **Plugins**: Support for 500+ tools via [asdf plugin ecosystem](https://github.com/asdf-vm/asdf-plugins)
- **Build-time**: Tools are installed during Docker build for optimal performance
- **Isolation**: Each tool combination creates a separate Docker image

### Performance Optimizations
- **Shared Base Layers**: Common system packages and Claude Code installation are shared across all workspace images (~500MB shared)
- **Incremental Builds**: Only rebuilds when Dockerfile or `.tool-versions` content actually changes
- **Content Hashing**: Tracks configuration changes to avoid unnecessary rebuilds
- **Layer Caching**: Docker layer caching minimizes build times for unchanged components

### Python Environment Details
- **System Python**: Python 3 installed via Debian package manager at `/usr/bin/python3` with symlink at `/usr/local/bin/python`
- **pip**: System pip3 available via Debian packages
- **uv**: Modern Python package manager installed per-user in `/home/node/.local/bin/uv`
- **Flexibility**: Users can use system Python directly or leverage uv for advanced package management

### Container Architecture
- **User**: Runs as non-root `node` user (UID 1000) for security
- **Permissions**: Uses gosu for proper privilege dropping
- **Docker Access**: Optional Docker-in-Docker via socket mounting with `-d` flag

## Troubleshooting

### Docker Build Issues

If you encounter build issues:

```bash
claude-code-sandbox --build
```

### Permission Issues

The container runs as the non-root `node` user (UID 1000). If you have permission issues with mounted volumes, ensure your files are accessible.

### Configuration Not Loading

Check that your Claude configuration files exist:

```bash
ls -la ~/.claude* ~/.anthropic* ~/.config/claude/
```

### Tool Installation Issues

If you encounter issues with specific tools:

```bash
# Check if tools were installed correctly from .tool-versions
claude-code-sandbox --build
claude-code-sandbox -n "java -version && python --version"

# Test with specific tool installation
claude-code-sandbox --build --install='python@3.12.8'
claude-code-sandbox -n "python --version"

# Debug asdf plugin issues
claude-code-sandbox -n "asdf plugin list all | grep terraform"

# Interactive debugging
claude-code-sandbox --shell
# Inside container: asdf list, which java, echo $PATH
```

### Python Environment Issues

If Python commands have issues, it may be because:
1. System Python packages conflict with user-installed packages
2. Path issues with uv installation (ensure `/home/node/.local/bin` is in PATH for uv usage)
3. Permission issues when installing packages system-wide vs user-local

Use the non-interactive mode to test Python setup:
```bash
claude-code-sandbox -n "python --version"
claude-code-sandbox -n "uv --version"

# Test with specific Python version
claude-code-sandbox -n --install='python@3.12.8' "python --version"
```

### Docker Not Running

Ensure Docker is installed and running:

```bash
docker --version
docker ps
```

## How It Works

1. **Workspace Image Management**: Each directory gets a unique Docker image name stored in `.claude-code-sandbox`
2. **Multi-stage Building**: Creates shared base image (`claude-code-sandbox-base`) then workspace-specific layers
3. **Incremental Builds**: Compares content hashes (Dockerfile + .tool-versions + --install) to determine if rebuild needed
4. **Dynamic Tools**: If `--install` is specified, [asdf](https://asdf-vm.com/) plugins are installed during build time
5. **Auto Tool Detection**: [`.tool-versions`](https://asdf-vm.com/manage/configuration.html#tool-versions) files are automatically parsed and installed if present
6. **Configuration Detection**: Automatically detects and mounts common development configurations
7. **Workspace Mounting**: Your current working directory is mounted as `/workspace` in the container
8. **Secure Execution**: Claude Code runs in the sandboxed environment with access to your project files
9. **Complete Isolation**: Each workspace has its own Docker image preventing tool conflicts between projects

## Security & Safety

**🛡️ Safe `--dangerously-skip-permissions` Usage:**
- The `--dangerously-skip-permissions` flag is automatically enabled but contained within Docker
- Even if Claude Code tries to modify system files, it can only affect the container
- Your host system remains completely protected from any potential damage
- No risk of accidentally deleting important files or breaking your system configuration

**Container Security:**
- All execution happens within a Docker container
- Only your current working directory and explicitly detected config directories are mounted
- The container runs with limited privileges
- No network access restrictions (Claude Code needs internet connectivity)
- Container is destroyed after each session - no persistent changes to the sandbox environment

## Prior Work

This project builds upon the excellent work of [claude-sandbox](https://github.com/cwensel/claude-sandbox) by Chris Wensel, which demonstrated the concept of running Claude Code safely in a Docker container.

## Contributing

Feel free to submit issues and pull requests to improve this wrapper.

## License

This wrapper is provided as-is. Please refer to the official Claude Code license for the underlying tool.