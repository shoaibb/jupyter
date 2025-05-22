#!/bin/bash

# Create JupyterLab configuration with GitHub extension
mkdir -p /root/.jupyter

# Create main JupyterLab configuration
cat > /root/.jupyter/jupyter_lab_config.py << EOF
# JupyterLab Configuration
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}

# GitHub Extension Configuration
if hasattr(c, 'GitHubConfig'):
    c.GitHubConfig.access_token = '${GITHUB_TOKEN}'
EOF

# Configure Git if environment variables are set
if [ ! -z "$GITHUB_NAME" ]; then
    git config --global user.name "$GITHUB_NAME"
fi

if [ ! -z "$GITHUB_EMAIL" ]; then
    git config --global user.email "$GITHUB_EMAIL"
fi

# Configure SSH if key is mounted
if [ -f /root/.ssh/id_ed25519 ]; then
    chmod 600 /root/.ssh/id_ed25519
    ssh-keyscan github.com >> /root/.ssh/known_hosts
fi

# Configure credential helper if token is provided
if [ ! -z "$GITHUB_TOKEN" ]; then
    git config --global credential.helper store
    echo "https://$GITHUB_TOKEN@github.com" > /root/.git-credentials
    chmod 600 /root/.git-credentials
elif [ ! -z "$GITHUB_TOKEN" ]; then
    # If no username provided, use token as both username and password
    git config --global credential.helper store
    echo "https://$GITHUB_TOKEN:$GITHUB_TOKEN@github.com" > /root/.git-credentials
    chmod 600 /root/.git-credentials
fi

if [ ! -z "$GITHUB_TOKEN" ]; then
    git config --global credential.helper '!f() { echo "username=${GITHUB_USERNAME:-$GITHUB_TOKEN}"; echo "password=$GITHUB_TOKEN"; }; f'
fi

# Start JupyterLab
exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --IdentityProvider.token="" --ServerApp.password=""
