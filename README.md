# Docker image for jupyter lab

The image uses:

    - bash
    - vim
    - wget
    - curl
    - pip
    - git and Github
    - jupyter lab
    - extensions & python packages in requirements.txt
    - python version 3.11
    - Github env variables (token, email, username) are read from a .env file

The .env file shold have your GitHub credentials, i.e. username, email, token, such as follows:

    GITHUB_TOKEN=your-token-here
    GITHUB_NAME=username
    GITHUB_EMAIL=first.lastname@email.com

To create an image:

    - docker build -t IMAGENAME .

Run container based on created image:

    - docker run -p 8800:8888 -v /path-to/your-project-dir:/app --env-file /path-to/.env IMAGENAME

    OR use following, if .env file is in the same dir:

    - docker run -p 8800:8888 -v ~/projects/jupy:/data --env-file .env IMAGENAME


The jupyterlab notebook can now be accessed at: http://127.0.0.1:8800/lab

In the notebook, you can access bash console login into your GitHub as follows:

    - gh auth login

To get a list of your repos:

    - gh repo list


Note: since your GitHub credentials are added as .env variables to the running container, you can use these for git related commands on your GitHub repos in bash from within your jupyterlab container.

