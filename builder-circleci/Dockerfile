FROM ubuntu:20.04

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=dumb \
  PAGER=cat

RUN \
  echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90depot && \
  echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90depot && \
  apt-get update && apt-get install -y curl locales sudo && \
  locale-gen en_US.UTF-8 && \
  rm -rf /var/lib/apt/lists/* && \
  useradd --uid=3434 --user-group --create-home circleci && \
  echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci && \
  echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

ENV \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8

RUN \
  apt-get update && apt-get install -y \
  apt-transport-https \
  autoconf \
  btrfs-progs \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  dpkg-repack \
  e2fsprogs \
  ffmpeg \
  gfortran \
  gnupg \
  gnupg-agent \
  gzip \
  imagemagick \
  jq \
  libarchive-tools \
  libcurl4-openssl-dev \
  libicu-dev \
  liblapack-dev \
  libmariadb-dev \
  libmariadb-dev-compat \
  libpq-dev \
  libssl-dev \
  libsqlite3-dev \
  lzop \
  make \
  mercurial \
  nano \
  net-tools \
  netcat \
  openssh-client \
  parallel \
  pkg-config \
  postgresql-client \
  protobuf-compiler \
  shellcheck \
  software-properties-common \
  sudo \
  tar \
  tzdata \
  uidmap \
  unzip \
  vim \
  wget \
  xfsprogs \
  zip && \
  add-apt-repository ppa:git-core/ppa && \
  apt-get install -y git && \
  rm -rf /var/lib/apt/lists/*

RUN \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2* && \
  echo 'AWS_PAGER=""' >> /etc/environment

ARG DOCKER_VERSION=5:20.10.17~3-0~ubuntu-
RUN \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository -y "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-get install -y "docker-ce=${DOCKER_VERSION}$(lsb_release -cs)" "docker-ce-cli=${DOCKER_VERSION}$(lsb_release -cs)" containerd.io && \
  docker --version && \
  rm -rf /var/lib/apt/lists/*

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN \
  addgroup --system dockremap && \
  adduser --system --ingroup dockremap dockremap && \
  echo 'dockremap:165536:65536' >> /etc/subuid && \
  echo 'dockremap:165536:65536' >> /etc/subgid && \
  usermod -a -G docker circleci

ARG COMPOSE_VER=2.6.0
ARG COMPOSE_SWITCH_VERSION=1.0.5
RUN \
  apt-get update && \
  apt-get install --yes --no-install-recommends docker-compose-plugin=${COMPOSE_VER}~ubuntu-$( lsb_release -cs ) && \
  curl -fL https://github.com/docker/compose-switch/releases/download/v${COMPOSE_SWITCH_VERSION}/docker-compose-linux-amd64 -o /usr/local/bin/compose-switch && \
  docker compose version && \
  chmod +x /usr/local/bin/compose-switch && \
  update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/compose-switch 99 && \
  docker-compose version && \
  rm -rf /var/lib/apt/lists/*

RUN \
  set -ex; \
  case "$(uname -m)" in \
  aarch64) arch='arm64' ;; \
  x86_64) arch='amd64' ;; \
  *) echo >&2 "error: unsupported architecture: $(uname -m)"; exit 1 ;; \
  esac; \
  curl -sSL "https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_$arch.tar.gz" | tar -xz -C /usr/local/bin && \
  mv /usr/local/bin/yq_linux_$arch /usr/local/bin/yq

ARG multirun_version=1.1.3
RUN \
  set -ex; \
  case "$(uname -m)" in \
  aarch64) arch='aarch64' ;; \
  x86_64) arch='x86_64' ;; \
  *) echo >&2 "error: unsupported architecture: $(uname -m)"; exit 1 ;; \
  esac; \
  curl -sSL https://github.com/nicolas-van/multirun/releases/download/${multirun_version}/multirun-$arch-linux-gnu-${multirun_version}.tar.gz | tar -xz; \
  mv multirun /bin

ARG agent_version=1.0.39853-df56b3e
ARG TARGETPLATFORM
RUN --mount=type=bind,source=files/install-launch-agent.sh,target=/install-launch-agent.sh /install-launch-agent.sh $agent_version $TARGETPLATFORM

RUN --mount=type=bind,source=files,target=/files \
  mkdir -p /etc/docker /opt/circleci && \
  cp /files/daemon.json /etc/docker/daemon.json && \
  cp /files/entrypoint.sh /entrypoint.sh && \
  cp /files/launch-agent-config.yaml /opt/circleci/launch-agent-config.yaml && \
  cp /files/start-circleci-launch-agent.sh /start-circleci-launch-agent.sh && \
  cp /files/start-dockerd.sh /start-dockerd.sh && \
  chown root: /opt/circleci/launch-agent-config.yaml && \
  chmod 600 /opt/circleci/launch-agent-config.yaml

USER circleci

RUN \
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
  git config --global --add safe.directory '*' && \
  docker buildx install && \
  echo 'export NVM_DIR="$HOME/.nvm"' >> /home/circleci/.bashrc && \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/circleci/.bashrc && \
  source /home/circleci/.nvm/nvm.sh && \
  nvm install lts/*

USER root

VOLUME /data/docker
ENTRYPOINT ["/entrypoint.sh"]
CMD []
