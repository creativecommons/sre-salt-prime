{{ sls }} remove sudoers:
  file.absent:
    - name: /etc/sudoers.d/90-cloud-init-users

{{ sls }} remove admin user:
  user.absent:
    - name: admin

{{ sls }} remove admin user home:
  file.absent:
    - name: /home/admin
    - require:
      - user: {{ sls }} remove admin user

{{ sls }} remove root ssh authorized_keys:
  file.absent:
    - name: /root/.ssh/authorized_keys
