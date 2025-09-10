# Also see states/salt/init.sls for logic determining version on salt-prime
# and Debian 12 (bookworm)
# Keeping the Salt version pinned at 3007.3 until the errors observed with 3007.4 are resolved
# refer to https://github.com/creativecommons/tech-support/issues/1347
  salt:
    minion_target_version: 3007.3
