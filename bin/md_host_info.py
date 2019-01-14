#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Create markdown table of host information:

sudo salt --out yaml \* grains.item lsb_distrib_description \
    saltversion | bin/md_host_info.py
"""

# Standard Libary
import datetime
import sys

# Third-party
import yaml


def main():
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    data = yaml.safe_load(sys.stdin)
    print()
    print("Host | Operating System | Salt Version")
    print("---- | ---------------- | ------------")
    for host in sorted(data.keys()):
        grains = data[host]
        if grains == "Minion did not return. [Not connected]":
            print(host, "| *N/A* | *Not connected*")
        else:
            print(host, "|", grains["lsb_distrib_description"], "|",
                  "`{}`".format(grains["saltversion"]))
    print("Generated {} via:".format(now))
    print("```shell")
    print("sudo salt --out yaml \* grains.item lsb_distrib_description"
          " saltversion \\")
    print("    | bin/md_host_info.py")
    print("```")
    print()


if __name__ == "__main__":
    main()
