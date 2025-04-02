FROM ubuntu:20.04
ARG TERRAGRUNT_VERSION=0.55.19
ARG OPENTOFU_VERSION=1.6.2

# Update apt and Install dependencies
RUN apt-get update && apt install software-properties-common -y && add-apt-repository ppa:rmescandon/yq -y && apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    tzdata \
    curl \
    dnsutils \
    git \
    jq \
    yq \
    libssl-dev \
    openvpn \
    python3 \
    python3-pip \
    screen \
    vim \
    wget \
    zip \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install tools and configure the environment

RUN wget -q https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip -O /tmp/tofu_${OPENTOFU_VERSION}_linux_amd64.zip \
    && unzip /tmp/tofu_${OPENTOFU_VERSION}_linux_amd64.zip -d /bin/ \
    && rm /tmp/tofu_${OPENTOFU_VERSION}_linux_amd64.zip

RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /bin/terragrunt \
    && chmod +x /bin/terragrunt

RUN pip3 install --upgrade pip \
    && mkdir /workdir && cd /workdir \
    && mkdir keys \
    && python3 -m pip install ansible==6.7.0 netaddr oci-cli openshift>=0.6 setuptools>=40.3.0 \
    && ansible-galaxy collection install community.kubernetes:2.3.2 oracle.oci community.general:9.5.5

COPY . iac-run-dir