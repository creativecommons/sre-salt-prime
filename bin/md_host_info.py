#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Create markdown table of host information:

sudo salt --out yaml \* grains.item lsb_distrib_description \\
    meta-data:public-ipv4 fqdn_ip4 saltversion \\
    | bin/md_host_info.py
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
    print("Host | Public IP | Operating System | Salt Version")
    print("---- | --------- | ---------------- | ------------")
    for host in sorted(data.keys()):
        grains = data[host]
        aws_ip = grains["meta-data:public-ipv4"]
        fqdn_ips = grains["fqdn_ip4"]
        if aws_ip:
            ip = "`{}`".format(aws_ip)
        elif fqdn_ips and fqdn_ips[0] and fqdn_ips[0] != "127.0.1.1":
            ip = "`{}`".format(fqdn_ips)
        else:
            ip = ""
        os = grains["lsb_distrib_description"]
        salt = "`{}`".format(grains["saltversion"])
        if grains == "Minion did not return. [Not connected]":
            print(host, "| *N/A* | *Not connected*")
        else:
            print(" | ".join([host, ip, os, salt]))
    print("Generated {} via:".format(now))
    print("```shell")
    print("sudo salt --out yaml \* grains.item lsb_distrib_description \\")
    print("    meta-data:public-ipv4 fqdn_ip4 saltversion \\")
    print("    | bin/md_host_info.py")
    print("```")
    print()


if __name__ == "__main__":
    main()
