#cloud-config
repo_update: true
repo_upgrade: all

packages:
- amazon-efs-utils
- docker

runcmd:
- mkdir -p ${efs_directory}
- echo "${file_system_id}:/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
- service docker start
- curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
- chmod +x /usr/local/bin/docker-compose
- usermod -a -G docker ec2-user
