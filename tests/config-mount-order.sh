#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# system-preconfigure.service runs preconfig.d/1000-init-bootfile, which
# copies config.boot.default to /opt/vyatta/etc/config/config.boot when that
# file is not readable. /opt/vyatta/etc/config is the bind mount of /config
# made by opt-vyatta-etc-config.mount. Unordered, the two race at boot: the
# test runs before the mount and the copy lands after it, overwriting the
# saved /config/config.boot with the default (the boot then drops every user
# the default does not have). The mount must be ordered before the service.
set -eu
unit=systemd/system/opt-vyatta-etc-config.mount
before=$(sed -n 's/^Before=//p' "$unit")
if ! printf '%s\n' "$before" | tr ' ' '\n' | grep -qx system-preconfigure.service; then
    echo "config-mount-order: $unit must have Before=system-preconfigure.service (has: $before)" >&2
    exit 1
fi
echo "config-mount-order: OK"
