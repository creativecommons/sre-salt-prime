#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Hash user supplied password and write to file.
"""

# Standard library
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


def pe(error):
    """Print error.
    """
    print()
    print(COLOR["error"], "ERROR: ", error, COLOR["reset"], sep="")
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


def main():
    username = getpass.getuser()
    path_script = os.path.dirname(os.path.abspath(inspect.stack()[0][1]))
    path_repo = os.path.dirname(path_script)
    path_passwords = os.path.join(path_repo, "pillars", "user", "passwords",
                                  "{}.sls".format(username))
    newpass = getpass.getpass("Enter new password: ")
    if newpass == getpass.getpass("Retype new password: "):
        if len(newpass) < PASS_MIN_LEN:
            pe("New password must be at least {} characters long"
               .format(PASS_MIN_LEN))
        hashedpass = crypt.crypt(newpass, crypt.METHOD_SHA512)
        data = {"user": {"passwords": {username: hashedpass}}}
        with open(path_passwords, "w") as passfile:
            ruamel.yaml.dump(data, passfile, default_flow_style=False)
        print()
        ph("REMINDER")
        pt("You still need to commit changes and apply the new password on all"
           " hosts. To update hosts, first update pillar data:")
        print()
        print("sudo salt \* saltutil.refresh_pillar")
        print()
        pt("Then preview changes (assuming \"{}\" environment):"
           .format(username))
        print()
        print("sudo salt \* state.apply user.admins saltenv={} test=True"
              .format(username))
        print()
        pt("Last, if there are no unexpected changes, simply run again with"
           " \"test=False\" and")
        pt("remember to ensure base environment is up-to-date.")
    else:
        pe("New password entries did not match.")


if __name__ == "__main__":
    main()
