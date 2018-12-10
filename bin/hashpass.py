#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

"""Hash user supplied password and write to file.
"""

# Standard library
import crypt
import getpass
import os
import inspect

# Third-party
import ruamel.yaml


username = getpass.getuser()
path_script = os.path.dirname(os.path.abspath(inspect.stack()[0][1]))
path_repo = os.path.dirname(path_script)
path_passwords = os.path.join(path_repo, "stacks", "01-common",
                              "user_passwords", "{}.yaml".format(username))
newpass = getpass.getpass("Enter new password: ")
if newpass == getpass.getpass("Retype new password: "):
    hashedpass = crypt.crypt(newpass, crypt.METHOD_SHA512)
    data = {"user": {"passwords": {username: hashedpass}}}
    with open(path_passwords, "w") as passfile:
        ruamel.yaml.dump(data, passfile, default_flow_style=False)
    print()
    print("REMINDER: you still need to commit changes and apply the new"
          " password on all hosts. To update hosts, first preview changes:")
    print()
    print("sudo salt \* state.apply user.admins test=True")
    print()
    print("If there are no unexpected changes, simply run again with"
          " test=False")
else:
    print()
    print("ERROR: New password entries did not match.")
