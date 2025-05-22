FROM python:3.11

RUN python -m pip install --upgrade pip

# Set the working directory to /data
WORKDIR /app

# Copy the current directory contents into the container at /data
COPY . /app

# Install Node.js (required for JupyterLab extensions)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs git vim


RUN pip install bash_kernel

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install additional extensions via jupyter labextension (if needed)
# Note: Most extensions are now distributed as pip packages, but some still require labextension install
RUN jupyter labextension install --no-build \
    @jupyter-widgets/jupyterlab-manager && \
    jupyter lab build --minimize=False


# Clean up to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    npm cache clean --force && \
    jupyter lab clean


# Create SSH directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Create startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

ENV SHELL=/bin/bash

# Create JupyterLab configuration directory and set terminal shell
RUN mkdir -p /root/.jupyter && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" > /root/.jupyter/jupyter_lab_config.py

RUN apt update && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && \
    apt-get install -y software-properties-common && \
    apt update && \
    apt install gh && \
    apt-get clean

# Create startup script for Git configuration
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Make port 8888 available
EXPOSE 8888

CMD ["/usr/local/bin/startup.sh"]
