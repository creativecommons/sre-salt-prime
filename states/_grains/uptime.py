#!/usr/bin/env python
# vim: set fileencoding=utf-8 :


def set_grains():
     grains = dict()
     with open("/proc/uptime", "r") as f:
        uptime_seconds = float(f.readline().split()[0])
     uptime_days = uptime_seconds / 86400
     grains["uptime_seconds"] = uptime_seconds
     grains["uptime_days"] = uptime_days
     return grains


if __name__ == "__main__":
    grains = set_grains()
    for key, value in grains.items():
        print("{}: {}".format(key, value))
