states:
  common: {{ sls }}
  postfix: {{ sls }}
  salt: {{ sls }}
  ssh: {{ sls }}
  sudo: {{ sls }}
  swapfile: {{ sls }}
  user: {{ sls }}
  vim: {{ sls }}
# Groups
# 9.2.2. UID and GID classes - 9. The Operating System - Debian Policy Manual
# https://www.debian.org/doc/debian-policy/ch-opersys.html#uid-and-gid-classes
groups:
  webdev: 4000
