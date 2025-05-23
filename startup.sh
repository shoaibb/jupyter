#!/bin/bash

# Create JupyterLab configuration with GitHub extension
mkdir -p /root/.jupyter

# Create main JupyterLab configuration
cat > /root/.jupyter/jupyter_lab_config.py << EOF
# JupyterLab Configuration
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
# GitHub Extension Configuration
EOF

# Only add GitHub token configuration if token is provided
if [ ! -z "$GITHUB_TOKEN" ]; then
    cat >> /root/.jupyter/jupyter_lab_config.py << EOF
if hasattr(c, 'GitHubConfig'):
    c.GitHubConfig.access_token = '${GITHUB_TOKEN}'
EOF
fi

# Configure Git if environment variables are set
if [ ! -z "$GITHUB_NAME" ]; then
    echo "Configuring Git user name: $GITHUB_NAME"
    git config --global user.name "$GITHUB_NAME"
fi

if [ ! -z "$GITHUB_EMAIL" ]; then
    echo "Configuring Git user email: $GITHUB_EMAIL"
    git config --global user.email "$GITHUB_EMAIL"
fi

# Configure SSH if key is mounted
if [ -f /root/.ssh/id_ed25519 ]; then
    echo "Configuring SSH key"
    chmod 600 /root/.ssh/id_ed25519
    ssh-keyscan github.com >> /root/.ssh/known_hosts 2>/dev/null
fi

# Configure Git credential helper if token is provided
if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "Configuring Git credentials"
    git config --global credential.helper store
    
    # Use username if provided, otherwise use token as username
    if [ ! -z "$GITHUB_USERNAME" ]; then
        echo "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com" > /root/.git-credentials
    else
        echo "https://$GITHUB_TOKEN@github.com" > /root/.git-credentials
    fi
    
    chmod 600 /root/.git-credentials
fi

# Print configuration status (without sensitive info)
echo "=== Git Configuration ==="
if [ ! -z "$GITHUB_NAME" ]; then
    echo "✓ Git user name configured"
fi
if [ ! -z "$GITHUB_EMAIL" ]; then
    echo "✓ Git user email configured"
fi
if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "✓ GitHub token configured"
fi
if [ -f /root/.ssh/id_ed25519 ]; then
    echo "✓ SSH key configured"
fi
echo "=========================="

# Start JupyterLab
echo "Starting JupyterLab..."
exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --IdentityProvider.token="" --ServerApp.password=""
