#cloud-config
repo_update: true
repo_upgrade: all

runcmd:
- mkdir -p ${efs_directory}
- echo "${file_system_id}:/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
- docker ${docker_cmd}