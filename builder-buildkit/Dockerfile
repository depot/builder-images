FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*

# Install buildkit
COPY --from=moby/buildkit:v0.10.4 /usr/bin/build* /usr/bin/

# Install machine-agent
RUN \
  mkdir -p /tmp/machine-agent && \
  cd /tmp/machine-agent && \
  curl -sLo machine-agent.tar.gz https://dl.depot.dev/machine-agent/download/linux/$(uname -m)/v0.0.18 && \
  tar -xzf machine-agent.tar.gz && \
  mv bin/machine-agent /usr/bin/ && \
  rm -rf /tmp/machine-agent

# Add config files
COPY buildkitd.toml /etc/buildkit/buildkitd.toml
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
