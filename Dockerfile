# Copyright 2022 Contributors to the Parsec project.
# SPDX-License-Identifier: Apache-2.0

FROM rust:1.60.0 as rustbuilder
WORKDIR /tools

# Clone and build the parsec-tool. We need a version that supports the 'encrypt'
# command, which is currently unreleased hence checking out specific commit below.
# TODO: replace commit hash with released tag when available.
RUN git clone https://github.com/parallaxsecond/parsec-tool.git
RUN cd parsec-tool \
         && git checkout 7e40ae9be21e797fe29186d19c3363ced70a8157 \
         && cargo build --release

WORKDIR /app
COPY rust/parsec-hello-decrypt parsec-hello-decrypt
RUN cd parsec-hello-decrypt && cargo build --release

FROM golang:1.18.1 as gobuilder
WORKDIR /app
COPY go/parsec-hello-decrypt parsec-hello-decrypt
RUN cd parsec-hello-decrypt && go get parsec/parsec-hello-decrypt && go build .

FROM ubuntu:20.04
RUN apt-get update
# Install OpenSSL in support of the parsec-cli-tests.sh script, which can optionally be executed
# by the client in place of the default hello-parsec.sh script.
RUN apt-get -y install openssl
WORKDIR /tools
COPY --from=rustbuilder /tools/parsec-tool/target/release/parsec-tool .
WORKDIR /app/rust
COPY --from=rustbuilder /app/parsec-hello-decrypt/target/release/parsec-hello-decrypt .
WORKDIR /app/go
COPY --from=gobuilder /app/parsec-hello-decrypt/parsec-hello-decrypt .
WORKDIR /demo
COPY --from=rustbuilder /tools/parsec-tool/tests/parsec-cli-tests.sh .
COPY hello-parsec.sh .
COPY parsec_banner.txt .
ENV PARSEC_TOOL=/tools/parsec-tool
ENV HELLO_DECRYPT_RUST=/app/rust/parsec-hello-decrypt
ENV HELLO_DECRYPT_GO=/app/go/parsec-hello-decrypt

CMD ["./hello-parsec.sh"]
