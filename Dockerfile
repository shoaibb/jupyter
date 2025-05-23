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
    apt-get install less && \
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

# git config for adding alias for add, commit, push
# usage: git acp "message-text"
RUN git config --global alias.acp '!f() { git add -A && git commit -m "$@" && git push; }; f'

# customize terminal appearance
RUN echo "export TERM=xterm-256color" >> /root/.bashrc
#RUN echo "export PS1='\[\e[32m\]shoaib\[\e[m\]->\[\e[34m\]\w\[\e[m\]:\$ '" >> /root/.bashrc
RUN echo "export LS_OPTIONS='--color=always'" >> /root/.bashrc
RUN echo "eval "$(dircolors)"" >> /root/.bashrc
RUN echo "alias ls='ls $LS_OPTIONS'" >> /root/.bashrc
RUN echo "alias ll='ls $LS_OPTIONS -l'" >> /root/.bashrc
RUN echo "alias l='ls $LS_OPTIONS -lA'" >> /root/.bashrc
RUN echo "alias ls='ls --color=always'" >> /root/.bashrc


# Expose port
EXPOSE 8888

# Set the startup command
CMD ["/usr/local/bin/startup.sh"]
