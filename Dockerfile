# Use appropriate base image
#FROM jupyter/base-notebook:latest
FROM python:3.11

# Switch to root user for installation
USER root

# Update pip
RUN python -m pip install --upgrade pip

# Set the working directory
WORKDIR /app

# Copy requirements and startup script only (not .env file)
COPY requirements.txt /app/
COPY startup.sh /usr/local/bin/startup.sh

# Install system dependencies
RUN apt-get update && \
    apt-get install -y curl git vim software-properties-common && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-get update && \
    apt-get install -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python packages
RUN pip install bash_kernel && \
    pip install --no-cache-dir -r requirements.txt

# Install JupyterLab extensions
RUN jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
    jupyter lab build --minimize=False && \
    jupyter lab clean && \
    npm cache clean --force

# Create necessary directories and set permissions
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    mkdir -p /root/.jupyter

# Make startup script executable
RUN chmod +x /usr/local/bin/startup.sh

# Set environment variables
ENV SHELL=/bin/bash

# Expose port
EXPOSE 8888

# Set the startup command
CMD ["/usr/local/bin/startup.sh"]
