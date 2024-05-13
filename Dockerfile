# Use Ubuntu as the base image
FROM ubuntu:latest

# Update package lists and install GCC
RUN apt-get update && \
    apt-get install -y gcc

# Specify the default command to run when the container starts
CMD ["tail", "-f", "/dev/null"]
