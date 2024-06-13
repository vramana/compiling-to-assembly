# Use an older version of Ubuntu as a parent image where the specific gcc-multilib for i386 is available
FROM ubuntu:20.04

# Set non-interactive installation to avoid stuck prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory to where xv6 will be built and run
WORKDIR /usr/src/xv6-public

# Install dependencies for building xv6 on x86
# and QEMU to emulate x86 architecture in terminal mode, and clean up cache to reduce layer size
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-multilib-i686-linux-gnu \
    gdb \
    qemu-system-x86 \
    vim \
    qemu-utils && \
    rm -rf /var/lib/apt/lists/*

# No cloning needed, assuming source code is mounted at runtime

# Install additional utilities for QEMU terminal operation if necessary
# For example, installing 'screen' or 'tmux' could be beneficial for managing terminal sessions
RUN apt-get update && apt-get install -y screen tmux

# Set the TOOLPREFIX to use the i386-specific GCC
ENV TOOLPREFIX=i686-linux-gnu-

# Optional: Set an environment variable or entrypoint script that configures QEMU to run in non-GUI mode
# This step is useful if you frequently run the QEMU command and want to avoid modifying it each time
ENV QEMU_AUDIO_DRV=none

# CMD changed to keep container running; builds are run manually
CMD ["/bin/bash"]

# Reset the frontend to its default value
ENV DEBIAN_FRONTEND=dialog
