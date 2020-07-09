#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Hash user supplied password and write to file.
"""

# Standard library
import argparse
import crypt
import getpass
import os
import inspect
import shutil
import sys
import textwrap

# Third-party
import ruamel.yaml


PASS_MIN_LEN = 10
COLOR = {"error": "\33[31m", "header": "\33[30m\33[107m", "reset": "\33[0m",
         "text": "\33[97m"}
COLUMNS, __ = shutil.get_terminal_size()


def pe(error, exit=None):
    """Print error.
    """
    exit = True if exit is None else exit
    print()
    print(COLOR["error"], "ERROR: ", error, COLOR["reset"], sep="")
    if exit:
        sys.exit(1)


def ph(header):
    """Print header.
    """
    header = "### {}".format(header)
    padding = " " * (COLUMNS - len(header))
    print(COLOR["header"], header, padding, COLOR["reset"], sep="")


def pt(text):
    """Print text.
    """
    print(COLOR["text"], textwrap.fill(text, width=COLUMNS), COLOR["reset"],
          sep="")


def print_reminder(args):
    """Print post password change reminder instructions.
    """
    print()
    ph("REMINDER")
    pt("You still need to commit changes and apply the new password on all"
       " hosts. To update hosts, first update pillar data:")
    print()
    print("sudo salt \* saltutil.refresh_pillar")
    print()
    pt("Then preview changes:")
    print()
    print("sudo salt \* state.apply user.admins saltenv=${USER} test=True")
    print()
    pt("Last, if there are no unexpected changes, simply run again with"
       " \"test=\" and")
    pt("remember to ensure base environment is up-to-date.")


def hash_and_write(args, newpass):
    hashedpass = crypt.crypt(newpass, crypt.METHOD_SHA512)
    data = {"user": {"passwords": {args.username: hashedpass}}}
    if args.dryrun:
        print()
        ph("DRY RUN")
        pt("{}:".format(args.path_passwords))
        ruamel.yaml.dump(data, sys.stdout, default_flow_style=False)
    else:
        with open(args.path_passwords, "w") as passfile:
            ruamel.yaml.dump(data, passfile, default_flow_style=False)


def setup():
    """Parse arguments.

    Return argparse namespace.
    """
    script_user = getpass.getuser()
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("-n", "--dryrun", action="store_true",
                    help="Dry run: do not make any changes.")
    ap.add_argument("-u", "--username", default=script_user,
                    help="Username to set password for")
    ap.add_argument("--script-user", default=script_user,
                    help=argparse.SUPPRESS)
    args = ap.parse_args()
    path_script = os.path.dirname(os.path.abspath(inspect.stack()[0][1]))
    path_repo = os.path.dirname(path_script)
    args.saltenv = os.path.basename(path_repo)
    args.path_passwords = os.path.join(path_repo, "pillars", "user",
                                       "passwords", "{}.sls"
                                       .format(args.username))
    return args


def main():
    args = setup()
    newpass = getpass.getpass("Enter new password: ")
    if newpass == getpass.getpass("Retype new password: "):
        if args.dryrun:
            exit = False
        else:
            exit = True
        if len(newpass) < PASS_MIN_LEN:
            pe("New password must be at least {} characters long"
               .format(PASS_MIN_LEN), exit)
        hash_and_write(args, newpass)
        print_reminder(args)
    else:
        pe("New password entries did not match.")


if __name__ == "__main__":
    main()
