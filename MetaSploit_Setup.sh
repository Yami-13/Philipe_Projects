#!/bin/bash

#Makes sure script is run as sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

#Sets up user to not need a password for sudo use
#Creates a new file in /etc/sudoers.d/ for the user
SUDOERS_FILE="/etc/sudoers.d/DeliveryBot-nopasswd"

#Ensure the /etc/sudoers.d/ directory exists
mkdir -p /etc/sudoers.d/

#Gives 'DeliveryBot' password-less sudo
echo "DeliveryBot  ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" > /dev/null

#Set the correct permissions for the new sudoers file (Syntax)
chmod 0440 "$SUDOERS_FILE"

#Create the 'DeliveryBot' user.
adduser --disabled-password --gecos ""  DeliveryBot

#Give the 'DeliveryBot' user sudo access
usermod -aG sudo DeliveryBot

#Passwd assignment to not make bro disabled
passwd -d DeliveryBot

#Makes the directory lil bro will put info into
mkdir /reports

#Makes it so lil vro is the owner/group owner of reports
chown DeliveryBot:DeliveryBot /reports

#Changing perms so only DeliveryBot can read/write/execute it
chmod 700 /reports

#Define the file to modify
FILE="/etc/inittab"

#Define the pattern to search for (the line you want to replace)
SEARCH_PATTERN="^# 1:2345:respawn:/sbin/getty --noclear 38400 tty1"

#Define the replacement line
REPLACEMENT_LINE="1:2345:respawn:/sbin/getty -a DeliveryBot --noclear 38400 tty1"

#Use sed to find and replace the line in-place
#-i: edit files in place
#s: substitute command
#/SEARCH_PATTERN/: regular expression to match the line
#/REPLACEMENT_LINE/: the new content to replace the matched line
#g: global replacement (replace all occurrences on the line, though for a whole line replacement, it's often redundant)
sed -i "s|$SEARCH_PATTERN|$REPLACEMENT_LINE|g" "$FILE"

