# Copyright 2022 Contributors to the Parsec project.
# SPDX-License-Identifier: Apache-2.0

FROM rust:1.60.0 as rustbuilder
WORKDIR /tools
RUN git clone https://github.com/parallaxsecond/parsec-tool.git
RUN cd parsec-tool && cargo build
WORKDIR /app
COPY rust/parsec-hello-decrypt parsec-hello-decrypt
RUN cd parsec-hello-decrypt && cargo build

FROM golang:1.18.1 as gobuilder
WORKDIR /app
COPY go/parsec-hello-decrypt parsec-hello-decrypt
RUN cd parsec-hello-decrypt && go get parsec/parsec-hello-decrypt && go build .

FROM ubuntu:20.04
WORKDIR /tools
COPY --from=rustbuilder /tools/parsec-tool/target/debug/parsec-tool .
WORKDIR /app/rust
COPY --from=rustbuilder /app/parsec-hello-decrypt/target/debug/parsec-hello-decrypt .
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
