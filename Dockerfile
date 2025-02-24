# Use a slim Python image as the base (consistent with dbt-core)
FROM python:3.11.6-slim-bookworm

# Set working directory
WORKDIR /usr/app

# Install system dependencies for PostgreSQL and dbt
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    git \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pip-tools

# Copy your dbt project files from the repo
COPY . .

RUN sh script.sh

# Set environment variables (optional, tweak as needed)
ENV DBT_PROFILES_DIR=/usr/app
ENV PYTHONUNBUFFERED=1

WORKDIR /usr/app/dbt/privilee
RUN dbt deps
ENTRYPOINT [ "bash" ]
