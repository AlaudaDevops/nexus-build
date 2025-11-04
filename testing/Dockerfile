FROM docker-mirrors.alauda.cn/library/golang:1.25.3-bookworm AS builder

WORKDIR /tools
RUN mkdir -p /tools/bin
COPY testing /app
# 安装 playwright
ENV GOPROXY='https://build-nexus.alauda.cn/repository/golang/,direct'
RUN set -eux; \
    cd /app && \
    CGO_ENABLED=0 go test -c -o /tools/bin/nexus.test ./

FROM registry.alauda.cn:60070/devops/nexus-ce-test-base:latest

RUN mkdir -p /tools/bin
COPY --from=builder /tools/bin /tools/bin

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
