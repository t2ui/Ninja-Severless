# 使用Alpine 3.16.6作为基础镜像
FROM alpine:3.16.6 as builder

ARG VERSION=0.9.31
ARG TARGETPLATFORM

# 根据目标平台确定架构和libc环境
RUN if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
        echo "aarch64" > /tmp/arch; \
        echo "musl" > /tmp/env; \
    elif [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        echo "x86_64" > /tmp/arch; \
        echo "musl" > /tmp/env; \
    elif [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then \
        echo "armv7" > /tmp/arch; \
        echo "musleabi" > /tmp/env; \
    elif [ "${TARGETPLATFORM}" = "linux/arm/v6" ]; then \
        echo "arm" > /tmp/arch; \
        echo "musleabi" > /tmp/env; \
    fi

# 安装wget并下载对应的ninja二进制文件
RUN apk update && apk add wget && \
    wget https://github.com/gngpp/ninja/releases/download/v${VERSION}/ninja-${VERSION}-$(cat /tmp/arch)-unknown-linux-$(cat /tmp/env).tar.gz -O /ninja.tar.gz && \
    tar -xvf /ninja.tar.gz -C /tmp

# 使用Alpine 3.16.6作为最终镜像
FROM alpine:3.16.6

LABEL org.opencontainers.image.authors="gngpp <gngppz@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/gngpp/ninja"
LABEL name="ninja"
LABEL url="https://github.com/gngpp/ninja"

ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=C

# 从构建阶段复制ninja二进制文件到最终镜像
COPY --from=builder /tmp/ninja /bin/ninja

RUN cp ninja /bin/ninja
RUN mkdir /.gpt3 && chmod 777 /.gpt3
RUN mkdir /.gpt4 && chmod 777 /.gpt4
RUN mkdir /.auth && chmod 777 /.auth
RUN mkdir /.platform && chmod 777 /.platform

COPY /hars /harfile
COPY /login-hars /login-harfile
CMD ["/bin/ninja", "run", "--arkose-gpt4-har-dir=/harfile", "--arkose-auth-har-dir=/login-harfile"]
