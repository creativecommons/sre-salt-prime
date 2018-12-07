#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Hash user supplied password and write to file.
"""

# Standard library
import crypt
import getpass

# Third-party
import ruamel.yaml


newpass = getpass.getpass("Enter new password: ")
username = getpass.getuser()
passpath = "stacks/01-common/user_passwords/{}.yaml".format(username)
if newpass == getpass.getpass("Retype new password: "):
    hashedpass = crypt.crypt(newpass, crypt.METHOD_SHA512)
    data = {"user": {"passwords": {username: hashedpass}}}
    with open(passpath, "w") as passfile:
        ruamel.yaml.dump(data, passfile, default_flow_style=False)
    print()
    print("REMINDER: you still need to update hosts and commit changes.")
else:
    print()
    print("ERROR: New password entries did not match.")
