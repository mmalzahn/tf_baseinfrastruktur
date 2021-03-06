#!/bin/bash
yum update -y
mkdir /usr/bin/bastion
mkdir /var/log/bastion


cat > /usr/bin/bastion/sync_users << 'EOF'
#!/bin/bash

# The file will log user changes
LOG_FILE="/var/log/bastion/users_changelog.txt"

# The function returns the user name from the public key file name.
# Example: public-keys/sshuser.pub => sshuser
get_user_name () {
  echo "$1" | sed -e 's/.*\///g' | sed -e 's/\.pub//g'
}

# For each public key available in the S3 bucket
aws s3api list-objects --bucket ${bucket} --prefix ${prefix} --region ${region} --output text --query 'Contents[?Size>`0`].Key' | sed -e 'y/\t/\n/' > ~/keys_retrieved_from_s3
while read line; do
  USER_NAME="`get_user_name "$line"`"

  # Make sure the user name is alphanumeric
  if [[ "$USER_NAME" =~ ^[a-z][-a-z0-9]*$ ]]; then

    # Create a user account if it does not already exist
    cut -d: -f1 /etc/passwd | grep -qx $USER_NAME
    if [ $? -eq 1 ]; then
      /usr/sbin/adduser $USER_NAME --shell /bin/false && \
      mkdir -m 700 /home/$USER_NAME/.ssh && \
      chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh && \
      echo "$line" >> ~/keys_installed && \
      echo "`date --date="today" "+%Y-%m-%d %H-%M-%S"`-[`hostname`]: Creating user account for $USER_NAME ($line)" >> $LOG_FILE
      aws --region ${region} sns publish --topic-arn "${topic_arn}" --subject "[$(hostname)] - NEW User $USER_NAME" --message "der User mit dem Username $USER_NAME wurde auf dem Host angelegt"
    fi

    # Copy the public key from S3, if a user account was created 
    # from this key
    if [ -f ~/keys_installed ]; then
      grep -qx "$line" ~/keys_installed
      if [ $? -eq 0 ]; then
        aws s3 cp s3://${bucket}/$line /home/$USER_NAME/.ssh/authorized_keys --region ${region}
        chmod 600 /home/$USER_NAME/.ssh/authorized_keys
        chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
      fi
    fi

  fi
done < ~/keys_retrieved_from_s3

# Remove user accounts whose public key was deleted from S3
if [ -f ~/keys_installed ]; then
  sort -uo ~/keys_installed ~/keys_installed
  sort -uo ~/keys_retrieved_from_s3 ~/keys_retrieved_from_s3
  comm -13 ~/keys_retrieved_from_s3 ~/keys_installed | sed "s/\t//g" > ~/keys_to_remove
  while read line; do
    USER_NAME="`get_user_name "$line"`"
    echo "`date --date="today" "+%Y-%m-%d %H-%M-%S"`-[`hostname`]: Removing user account for $USER_NAME ($line)" >> $LOG_FILE
    aws --region ${region} sns publish --topic-arn "${topic_arn}" --subject "[$(hostname)] - REMOVE User $USER_NAME" --message "der User mit dem Username $USER_NAME wurde vom Host entfernt"
    /usr/sbin/userdel -r -f $USER_NAME
  done < ~/keys_to_remove
  comm -3 ~/keys_installed ~/keys_to_remove | sed "s/\t//g" > ~/tmp && mv ~/tmp ~/keys_installed
fi

EOF

# cat > /usr/bin/bastion/upload_logs << 'EOF'
# #!/bin/bash

# # The file will log user changes
# LOG_FILE="/var/log/bastion/users_changelog.txt"
# KEY_LOGFILE = "bastionlogs/$(hostname)_userlog.txt"
# aws s3api put-object --bucket ${bucket} --key $KEY_LOGFILE --body $LOG_FILE

# EOF

chmod 700 /usr/bin/bastion/sync_users
#chmod 700 /usr/bin/bastion/upload_logs

cat > ~/mycron << EOF
*/2 * * * * /usr/bin/bastion/sync_users
0 0 * * * yum -y update --security
EOF
crontab ~/mycron
rm ~/mycron
