#!/bin/sh

set -x

rm -rf /var/lib/buildkit/runc-native || true

# Format the buildkit storage mount for better inode ratio
if ! [ -f /var/lib/buildkit/.formatted ]; then
  umount /var/lib/buildkit || true
  mkfs.ext4 -T news -F /dev/vdb
  mount /dev/vdb /var/lib/buildkit
  touch /var/lib/buildkit/.formatted
fi

exec /usr/bin/machine-agent start
