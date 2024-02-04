FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y curl

COPY ninja-0.9.20-x86_64-unknown-linux-musl.tar.gz /ninja.tar.gz
RUN tar -xzf /ninja.tar.gz

ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=C

RUN cp ninja /bin/ninja
RUN mkdir /.gpt3 && chmod 777 /.gpt3
RUN mkdir /.gpt4 && chmod 777 /.gpt4
RUN mkdir /.auth && chmod 777 /.auth
RUN mkdir /.platform && chmod 777 /.platform

COPY /hars /harfile
CMD ["/bin/ninja", "run", "--arkose-gpt4-har-dir=/harfile"]
