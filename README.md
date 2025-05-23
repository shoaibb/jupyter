# JupyterLab with GitHub Integration

A Docker container that provides JupyterLab with GitHub integration, allowing users to authenticate with their own GitHub credentials.

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A GitHub Personal Access Token

### Setup

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. **Create your environment file**
   ```bash
   cp .env.template .env
   ```

3. **Edit the `.env` file with your GitHub credentials**
   ```bash
   # Required: GitHub Personal Access Token
   GITHUB_TOKEN=ghp_your_token_here
   
   # Required: Your GitHub info
   GITHUB_NAME=Your Name
   GITHUB_EMAIL=your.email@example.com
   
   # Optional: GitHub username (if different from token)
   GITHUB_USERNAME=your_username
   ```

4. **Start the container**
   ```bash
   docker-compose up -d
   ```

5. **Access JupyterLab**
   Open http://localhost:8888 in your browser

## GitHub Personal Access Token

To create a GitHub Personal Access Token:

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a descriptive name
4. Select appropriate scopes:
   - `repo` (for repository access)
   - `workflow` (if you need to work with GitHub Actions)
   - `user:email` (for email access)
5. Click "Generate token"
6. Copy the token immediately (you won't see it again)

## Usage Options

### Option 1: Docker Compose
```bash
docker-compose up -d
```

### Option 2: Docker Run with env variables
```bash
docker run -d \
  -p 8888:8888 \
  -e GITHUB_TOKEN=your_token \
  -e GITHUB_NAME="Your Name" \
  -e GITHUB_EMAIL="your.email@example.com" \
  -v $(pwd)/workspace:/app \
  your-image-name
```

### Option 2a: Docker run with env variables in a file
```bash
docker run -d \
  -p 8800:8888 \
  --env-file .env \
  -v $(pwd)/workspace:/app \  
  your-image-name
```

### Option 2b: Docker run without Github credentials in container
```bash
docker run -d \
-p 8800:8888 \
-v $(pwd)/workspace:/app \
your-image-name
```


### Option 3: With SSH Keys
If you prefer SSH-based Git operations:
```bash
docker run -d \
  -p 8888:8888 \
  -e GITHUB_NAME="Your Name" \
  -e GITHUB_EMAIL="your.email@example.com" \
  -v ~/.ssh:/root/.ssh:ro \
  -v $(pwd)/workspace:/app \
  your-image-name
```

## Directory Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── startup.sh
├── requirements.txt
├── .env.template
├── .env (create this from template)
└── .gitignore/ 
```

## Security Notes

- Never commit your `.env` file to version control
- The `.env.template` file is included as a reference
- Your GitHub token is only used at runtime, not baked into the image
- SSH keys are mounted read-only if you choose to use them

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GITHUB_TOKEN` | Yes | Your GitHub Personal Access Token |
| `GITHUB_NAME` | Yes | Your full name for Git commits |
| `GITHUB_EMAIL` | Yes | Your email for Git commits |
| `GITHUB_USERNAME` | No | Your GitHub username (optional) |

## Building Your Own Image

If you want to build and share your own version:

### DockerHub image
```bash
# Build the image
docker build -t your-dockerhub-username/jupyter-github:latest .

# Push to Docker Hub
docker push your-dockerhub-username/jupyter-github:latest
```
### Local image

```bash
# Build the image
docker build -t jupyter-github:latest .
```

## Troubleshooting

### Git Authentication Issues
- Ensure your GitHub token has the correct permissions
- Check that your token isn't expired
- Verify the token is correctly set in your `.env` file

### Container Won't Start
- Check that port 8888 isn't already in use
- Verify all required environment variables are set
- Check Docker logs: `docker-compose logs`

### SSH Key Issues
- Ensure SSH keys are properly formatted and have correct permissions
- Make sure the public key is added to your GitHub account
- Verify the private key path in the volume mount
