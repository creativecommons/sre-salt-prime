# Informed by:
#   How-To: Reboot on OOM - Debuntu
#   https://www.debuntu.org/how-to-reboot-on-oom/


# https://sysctl-explorer.net/kernel/panic/
# > number of seconds the kernel waits before rebooting on a panic
{{ sls }} kernel.panic:
  sysctl.present:
    - name: kernel.panic
    - value: 15


# https://sysctl-explorer.net/vm/panic_on_oom/
# > If this is set to 1, the kernel panics when out-of-memory happens. However,
# > if a process limits using nodes by mempolicy/cpusets, and those nodes become
# > memory exhaustion status, one process may be killed by oom-killer. No panic
# > occurs in this case. Because other nodes’ memory may be free. This means
# > system total status may be not fatal yet.
{{ sls }} vm.panic_on_oom:
  sysctl.present:
    - name: vm.panic_on_oom
    - value: 1
    - require:
      - sysctl: {{ sls }} kernel.panic
