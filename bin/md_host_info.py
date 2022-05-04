#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

r"""Create markdown table of host information:

sudo salt \* saltutil.sync_grains saltenv=${USER}
sudo salt --out yaml \* grains.item saltenv=${USER} debian_version \
    lsb_distrib_codename meta-data:public-ipv4 fqdn_ip4 saltversion \
    uptime_days \
    | bin/md_host_info.py
"""

# Standard library
# Standard Libary
import datetime
import sys

# Third-party
import yaml


def format_columns(rows, sep=None, align=None):
    """Convert a list (rows) of lists (columns) to a formatted list of lines.
    When joined with newlines and printed, the output is similar to
    `column -t`.

    The optional align may be a list of alignment formatters.

    The last (right-most) column will not have any trailing whitespace so that
    it wraps as cleanly as possible.

    Based on MIT licensed:
    https://github.com/ClockworkNet/OpScripts/blob/master/opscripts/utils/v8.py

    Based on solution provided by antak in http://stackoverflow.com/a/12065663
    """
    lines = list()
    if sep is None:
        sep = "  "
    widths = [max(map(len, map(str, col))) for col in zip(*rows)]
    for row in rows:
        formatted = list()
        last_col = len(row) - 1
        for i, col in enumerate(row):
            # right alighed
            if align and align[i].lower() in (">", "r"):
                formatted.append(str(col).rjust(widths[i]))
            # center aligned
            elif align and align[i].lower() in ("^", "c"):
                col_formatted = str(col).center(widths[i])
                if i == last_col:
                    col_formatted = col_formatted.rstrip()
                formatted.append(col_formatted)
            # left aligned
            else:
                if i == last_col:
                    formatted.append(str(col))
                else:
                    formatted.append(str(col).ljust(widths[i]))
        lines.append("| {} |".format(sep.join(formatted)))
    return lines


def main():
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    data = yaml.safe_load(sys.stdin)
    print()
    align = ["l", "c", "l", "l", "l", "r"]
    rows = list()
    rows.append(
        [
            "Host (Salt Minion ID)",
            "Public IP",
            "OS Rel",
            "OS Code",
            "Salt Ver",
            "Days Up",
        ]
    )
    rows.append(
        [
            "---------------------",
            ":-------:",
            "------",
            "-------",
            "--------",
            "------:",
        ]
    )
    for host in sorted(data.keys()):
        grains = data[host]
        uptime = int(grains["uptime_days"])
        if uptime <= 30:
            uptime_desc = "0 - 30"
        elif 30 < uptime <= 60:
            uptime_desc = "30 - 60"
        elif 60 < uptime <= 90:
            uptime_desc = "60 - 90"
        elif 90 < uptime <= 120:
            uptime_desc = "90 - 120"
        elif 120 < uptime <= 180:
            uptime_desc = ":warning: **120 - 180**"
        elif 180 < uptime <= 270:
            uptime_desc = ":warning: **180 - 270**"
        elif 270 < uptime <= 360:
            uptime_desc = ":warning: **270 - 360**"
        else:
            uptime_desc = ":warning: **360+**"
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
        os_rel = grains["debian_version"]
        os_code = grains["lsb_distrib_codename"].title()
        salt_f = "{}".format(grains["saltversion"])
        if grains == "Minion did not return. [Not connected]":
            print(host, "| *N/A* | *Not connected*")
            rows.append(
                [host_f, "*N/A*", "*N/A*", "Not connected", "*N/A*" "*N/A*"]
            )
        else:
            rows.append([host_f, ip_f, os_rel, os_code, salt_f, uptime_desc])
    print("\n".join(format_columns(rows, " | ", align=align)))
    print()
    print("- **`{}`** total hosts".format(len(rows) - 2))
    print("- All hosts are running the Debian GNU/Linux operating system (OS)")
    print("- Generated {} via:".format(now))
    print("    ```shell")
    print("    sudo salt \\* saltutil.sync_grains saltenv=${USER}")
    print(
        "    sudo salt --out yaml \\* grains.item saltenv=${USER}"
        " debian_version \\"
    )
    print(
        "        lsb_distrib_codename meta-data:public-ipv4 fqdn_ip4"
        " saltversion \\"
    )
    print("        uptime_days \\")
    print("        | bin/md_host_info.py")
    print("    ```")
    print()


if __name__ == "__main__":
    main()
