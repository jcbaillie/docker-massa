FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -q -y apt-utils && \
    apt-get dist-upgrade -q -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y --fix-missing \
            pkg-config curl git build-essential libssl-dev \
            curl git-core vim mlocate wget 
RUN rm -rf /tmp/* /var/tmp/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.rs && chmod a+x rustup.rs && sh rustup.rs -y

RUN ln -sf /bin/bash /bin/sh

RUN git clone --branch testnet https://gitlab.com/massalabs/massa.git
RUN source $HOME/.cargo/env && rustup toolchain install nightly
RUN source $HOME/.cargo/env && rustup default nightly

WORKDIR /massa/massa-client
RUN bash -c "source $HOME/.cargo/env && cargo build --release"

WORKDIR /massa/massa-node
RUN bash -c "source $HOME/.cargo/env && cargo build --release"

ENTRYPOINT ["bash","-c","source $HOME/.cargo/env && RUST_BACKTRACE=full cargo run --release"]
EXPOSE 33033
