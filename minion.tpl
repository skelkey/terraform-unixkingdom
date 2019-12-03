packages:
  - salt-minion

write_files:
  - content: |
      master: ${saltmaster}
    path: /etc/salt/minion
    owner: root:root
    permissions: '0644'

runcmd:
  - [ systemctl, enable, salt-minion ]
  - [ systemctl, start, salt-minion ]
