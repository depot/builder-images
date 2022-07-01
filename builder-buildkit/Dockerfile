FROM moby/buildkit:v0.10.1
RUN apk add --no-cache e2fsprogs-extra
COPY buildkitd.toml /etc/buildkit/buildkitd.toml
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
