#!/usr/bin/env python
# vim: set fileencoding=utf-8 :


def set_grains():
    grains = dict()
    with open("/etc/debian_version", "r") as f:
        debian_version = f.readline().strip()
    grains["debian_version"] = debian_version
    return grains


if __name__ == "__main__":
    grains = set_grains()
    for key, value in grains.items():
        print("{}: {}".format(key, value))
