#!/bin/bash
yum_update yum update -y
yum install -y nfs-utils
yum install -y docker
service docker start
curl -L https://github.com/docker/compose/releases/download/1.22.0-rc2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -a -G docker ec2-user

mkdir /efs
mkdir /efs/revproxy1
chmod 666 /efs/revproxy1
