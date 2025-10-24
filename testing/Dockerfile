FROM docker-mirrors.alauda.cn/library/golang:1.23.7-bookworm AS builder

WORKDIR /tools
RUN mkdir -p /tools/bin

ARG YQ_VERSION=4.25.2
ARG KUBECTL_VERSION=1.28.2
ARG HELM_VERSION=3.12.3
ARG DOCKER_VERSION=26.0.2
ARG MAVEN_VERSION=3.9.11

RUN set -eux; \
    if [ "$(arch)" = "arm64" ] || [ "$(arch)" = "aarch64" ]; then \
    export ARCH="arm64"; \
    export ARCH_ALIAS="arm64"; \
    else \
    export ARCH="amd64"; \
    export ARCH_ALIAS="x86_64"; \
    fi; \
    mkdir -p /tools/bin/maven; \
    curl -fsSLO https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    tar xzvf apache-maven-${MAVEN_VERSION}-bin.tar.gz  --strip 1 -C ./bin/maven; \
    curl -fsSLO https://download.docker.com/linux/static/stable/$(arch)/docker-${DOCKER_VERSION}.tgz; \
    tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 -C ./bin docker/docker; \
    curl -sfL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH} -o ./bin/yq; \
    curl -sfL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -o ./bin/kubectl; \
    mkdir -p tmp; \
    curl -sfL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar xzf - -C tmp 2>&1 && mv tmp/linux-${ARCH}/helm ./bin; \
    chmod +x ./bin/*; \
    rm -rf tmp; \
    ./bin/yq --version; \
    ./bin/kubectl version --client; \
    ./bin/helm version

COPY testing /app
# 安装 playwright
ENV GOPROXY='https://build-nexus.alauda.cn/repository/golang/,direct'
RUN set -eux; \
    cd /app && \
    CGO_ENABLED=0 go test -c -o /tools/bin/nexus.test ./

FROM docker-mirrors.alauda.cn/library/python:3.12-slim

RUN mkdir -p /tools/bin
COPY --from=builder /tools/bin /tools/bin

RUN echo "deb https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib" > /etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian-security/ bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib" >> /etc/apt/sources.list

# install playwright dependencies
RUN apt-get update && apt-get install -y ca-certificates tzdata bash locales make git \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    nodejs \
    npm \
    openjdk-17-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && locale-gen zh_CN.UTF-8 \
    && update-locale \
    && chmod 755 /bin/sh

ARG ALLURE_VERSION=2.24.1
RUN wget https://github.com/allure-framework/allure2/releases/download/${ALLURE_VERSION}/allure-${ALLURE_VERSION}.tgz \
    && tar -zxvf allure-${ALLURE_VERSION}.tgz -C /opt/ \
    && ln -s /opt/allure-${ALLURE_VERSION}/bin/allure /usr/local/bin/allure \
    && rm allure-${ALLURE_VERSION}.tgz

COPY . /app

RUN chmod -R 755 /app

WORKDIR /app/testing

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r nexus-e2e/requirements.txt
RUN pip install build setuptools

ENV PATH=/tools/bin:/tools/bin/maven/bin:$PATH
ENV CI=true
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV TEST_COMMAND="nexus.test"

ENTRYPOINT ["nexus.test"]
CMD ["--godog.concurrency=2", "--godog.format=allure", "--godog.tags= ~@e2e"]
