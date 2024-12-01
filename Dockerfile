# Use Ubuntu as the base image
FROM gcc:latest

# Specify the default command to run when the container starts
CMD ["tail", "-f", "/dev/null"]
