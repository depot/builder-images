#!/bin/bash
set -eu

find /run /var/run -iname 'docker*.pid' -delete || :

if dockerd --version | grep -qF ' 20.10.'; then
  set -- docker-init -- "$@"
fi

if ! iptables -nL > /dev/null 2>&1; then
  modprobe ip_tables || :
fi

# apparmor sucks and Docker needs to know that it's in a container (c) @tianon
export container=docker

if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security; then
  mount -t securityfs none /sys/kernel/security || {
    echo >&2 'Could not mount /sys/kernel/security.'
    echo >&2 'AppArmor detection and --privileged mode might break.'
  }
fi

# Mount /tmp (conditionally)
if ! mountpoint -q /tmp; then
  mount -t tmpfs none /tmp
fi

# cgroup v2: enable nesting
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
  # move the processes from the root group to the /init group,
  # otherwise writing subtree_control fails with EBUSY.
  # An error during moving non-existent process (i.e., "cat") is ignored.
  mkdir -p /sys/fs/cgroup/init
  xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  # enable controllers
  sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers > /sys/fs/cgroup/cgroup.subtree_control
fi

exec dockerd "$@"
