#!/bin/bash

#Makes sure script is run as sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

#Sets up user to not need a password for sudo use
#Creates a new file in /etc/sudoers.d/ for the user
SUDOERS_FILE="/etc/sudoers.d/RecievingBot-nopasswd"

#Ensure the /etc/sudoers.d/ directory exists
mkdir -p /etc/sudoers.d/

#Gives 'RecievingBot' password-less sudo
echo "RecievingBot  ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" > /dev/null

#Set the correct permissions for the new sudoers file (Syntax)
chmod 0440 "$SUDOERS_FILE"

#Create the 'RecievingBot' user.
adduser --disabled-password --gecos "" RecievingBot

#Give the 'RecievingBot' user sudo access
usermod -aG sudo RecievingBot

#Passwd assignment to not make bro disabled
passwd -d RecievingBot

#Makes lil bro's home directory
mkdir /home/.RecievingBot

#Makes lil bro the owner and group owner of his home
chown RecievingBot:RecievingBot  /home/.RecievingBot

#Gives only lil vro permissions to do anything within or with his directory.
chmod 700 /home/.RecievingBot

#Makes the directory lil bro will put info into
mkdir /.reports

#Makes it so lil vro is the owner/group owner of reports
chown RecievingBot:RecievingBot /.reports

#Changing perms everyone  can read/write/execute in it
chmod 777 /.reports

#Adds private key to lil vro's directory
cp ./id_rsa /home/.RecievingBot/.ssh/
