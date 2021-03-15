FROM rustdocker/rustup AS seed_rust

ADD Cargo.toml Cargo.lock deny.toml rust-toolchain /app/
ADD keyutil /app/keyutil/
ADD seed/Cargo.toml /app/seed/
ADD seed/src /app/seed/src/
WORKDIR /app
RUN /root/.cargo/bin/cargo version
RUN /root/.cargo/bin/cargo build --release

FROM node AS seed_node
ADD seed/ui /app/ui/
WORKDIR /app/ui
RUN yarn
RUN yarn build

FROM debian:10-slim
COPY --from=seed_rust /app/target/release/radicle-keyutil /usr/local/bin/
COPY --from=seed_rust /app/target/release/radicle-seed-node /usr/local/bin/
COPY --from=seed_node /app/ui/public /usr/local/share/radicle/public/
