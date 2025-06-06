#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up a new project"

read -p "Project Name: " PROJECT_NAME
read -p "Base Image (e.g. python:3.11, node:18-alpine): " BASE_IMAGE
read -p "Application default port (e.g 8000, 3000, 8080): " APP_PORT
read -p "Install Command (e.g. pip install -r requirements.txt or npm install): " INSTALL_COMMAND
read -p "Start Command (e.g. 'python', 'npm', 'node'): " START_CMD
read -p "Start Script/File (e.g. src/main.py, index.js): " ENTRY_FILE
read -p "Maintainers --> separate values with a comma (e.g test@test.com, example.com): " MAINTAINER
read -p "Github Remote Origin (value entered will be used to set your git origin): " REMOTE_ORIGIN


# --- Create Project Directory ---
echo "Generating Directory..."

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: Directory '$PROJECT_NAME' already exists."
  exit 1
fi

mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME"


echo "Creating virtual environment with Pipenv..."

pipenv install 
pipenv install django djangorestframework django-cors-headers drf-yasg djangorestframework-simplejwt


# Generate Dockerfile dynamically
cat <<EOF > Dockerfile
FROM $BASE_IMAGE

LABEL maintainers=$MAINTAINER

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git gcc libpq-dev python3-dev curl binutils \
    libproj-dev libgdal-dev python3-gdal gdal-bin \
    gnome-terminal \
    && python -m pip install --upgrade pip

RUN mkdir /app
WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN $INSTALL_COMMAND
EOF


# Basic docker-compose
cat <<EOF > docker-compose.yml
version: "3.9"

services:
  app:
    build: .
    ports:
      - "127.0.0.1:$APP_PORT:$APP_PORT"
    volumes:
      - .:/app
EOF


echo "git remote '$REMOTE_ORIGIN'"
echo $PROJECT_NAME

# --- Initialize Git (optional) ---
# https://docs.github.com/en/get-started/git-basics/managing-remote-repositories
if command -v git &> /dev/null; then
    echo "Initializing Git repository..."
    git init
    git remote add origin "$REMOTE_ORIGIN"
    cat << GITIGNORE_EOF > .gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
#   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
#   However, in case of collaboration, if having platform-specific dependencies or dependencies
#   having no cross-platform support, pipenv may install dependencies that don't work, or not
#   install all needed dependencies.
#Pipfile.lock

# PEP 582; used by e.g. github.com/David-OConnor/pyflow
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# Vscode settings
.vscode/

# Migrations
migrations/

data/
static/
daphne_keys/

todo.md

# mac
.DS_Store
GITIGNORE_EOF
fi


git add . &&
git commit -m "Feat: Initial project setup"


echo "✅ Project '$PROJECT_NAME' created and initialized. 🎉"


echo "Entering virtual environment to Create and start Django project 🚀"
pipenv shell
django admin startproject "$PROJECT_NAME"
python3 manage.py runserver
