#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Create markdown table of host information:

sudo salt \* saltutil.sync_grains
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
    print("Cnt | Host | Public IP | Operating System | Salt Version | Days Up")
    print("--: | ---- | :-------: | ---------------- | ------------ | ------:")
    i = 1
    for host in sorted(data.keys()):
        grains = data[host]
        uptime = grains["uptime_days"]
        if uptime > 90.0:
            b = "**"
            count_f = "{}{}{}".format(b, i, b)
        else:
            b = ""
            count_f = "{: 3d}".format(i)
        if "meta-data:public-ipv4" in grains:
            aws_ip = grains["meta-data:public-ipv4"]
        else:
            aws_ip = False
        if "fqdn_ip4" in grains:
            fqdn_ips = grains["fqdn_ip4"]
        else:
            fqdn_ips = False
        if aws_ip:
            ip_f = aws_ip
        elif fqdn_ips and fqdn_ips[0] and fqdn_ips[0] != "127.0.1.1":
            ip_f = fqdn_ips[0]
        else:
            ip_f = ""
        host_f = "`{}`".format(host)
        os_f = grains["lsb_distrib_description"]
        salt_f = "{}".format(grains["saltversion"])
        uptime_f = "{}{:.2f}{}".format(b, uptime, b)
        if grains == "Minion did not return. [Not connected]":
            print(host, "| *N/A* | *Not connected*")
        else:
            print(" | ".join([count_f, host_f, ip_f, os_f, salt_f, uptime_f]))
        i += 1
    print()
    print("Generated {} via:".format(now))
    print("```shell")
    print("sudo salt \\* saltutil.sync_grains")
    print("sudo salt --out yaml \\* grains.item lsb_distrib_description \\")
    print("    meta-data:public-ipv4 fqdn_ip4 saltversion uptime_days \\")
    print("    | bin/md_host_info.py")
    print("```")
    print()


if __name__ == "__main__":
    main()
