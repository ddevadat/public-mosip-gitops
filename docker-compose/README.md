# MOSIP Control Center Docker Setup

This repository contains the necessary Docker setup to run the **MOSIP Control Center** environment using Docker. You can choose between running the setup using **Docker Compose** or **Docker** directly.

## Prerequisites

Before you begin, ensure that you have the following installed on your system:

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/) (if using Docker Compose)

## Clone the repository:
   First, clone this repository to your local machine.

   ```bash
   git clone <repository-url> -b mosip-document
   cd <repository-directory>/docker-compose
   ```

## Docker Compose Method

Start the deployment control center 
   ```bash
   docker compose up --build
   ```

## Docker  Method

Start the deployment control center 
   ```bash
      docker build -t mosip-control-center . && \
      docker run -d \
      --name mosip-control-center \
      --entrypoint "sh" \
      mosip-control-center -c "tail -f /dev/null"



   ```

## Set Environment Variables & Infra Provisioning

   ```bash
    docker exec -it mosip-control-center /bin/bash

    cd /iac-run-dir
    modify environment variables in setenv as appropriate

    source setenv
    ./init.sh
    cd /iac-run-dir/mosip-gitops/terragrunt/mosip/dev
    modify environment.yaml file as appropriate
    ./run.sh

   ```

