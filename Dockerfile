#原作者有dockerfile：https://github.com/gngpp/ninja/blob/main/docker/Dockerfile
#但是由于render免费版没有数据盘，har文件会丢失，必须在部署时写死，此dockerfile仅改变上述。
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

# 创建必要的目录并设置权限
RUN mkdir /.gpt3 && chmod 777 /.gpt3 && \
    mkdir /.gpt4 && chmod 777 /.gpt4 && \
    mkdir /.auth && chmod 777 /.auth && \
    mkdir /.platform && chmod 777 /.platform

COPY /hars /.gpt4

COPY /login-hars /.auth


# 定义容器启动时执行的命令及其参数
ENTRYPOINT ["/bin/ninja"]
CMD ["run", "--arkose-solver-key=12345678", "--arkose-solver=fcsrv", "--arkose-solver-endpoint=https://fcsrv-severless.onrender.com/task"]
