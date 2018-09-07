#cloud-config
repo_update: true
repo_upgrade: all

runcmd:
- yum update -y
- yum install -y amazon-efs-utils
- mkdir -p /efs
- echo "${file_system_id}:/ /efs efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
