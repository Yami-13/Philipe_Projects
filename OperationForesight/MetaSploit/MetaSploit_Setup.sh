#!/bin/bash

#Makes sure script is run as sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

#Saves receiving machine IP
read -p "Please enter the IP of the machine you would like the parsed logs sent to: " rec_ip

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
mkdir /.reports

#Makes lil bro's home directory
mkdir /home/.DeliveryBot

#Makes lil bro the owner and group owner of his home
chown DeliveryBot:DeliveryBot  /home/.DeliveryBot

#Gives only lil vro permissions to do anything within or with his directory.
chmod 700 /home/.DeliveryBot

#Makes it so lil vro is the owner/group owner of reports
chown DeliveryBot:DeliveryBot /.reports

#Changing perms so only DeliveryBot can read/write/execute it
chmod 700 /.reports


#Adds public key to lil vro's directory
cp ./id_rsa.pub /home/.DeliveryBot/.ssh/


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

touch /usr/local/sbin/LogDelivery.sh

echo '#!/bin/bash

# Define log files to monitor
AUTH_LOG="/var/log/auth.log"
SYSLOG="/var/log/syslog"
KERN_LOG="/var/log/kern.log"

# Define output report file
REPORT_FILE="/.reports/security_report_$(date +%Y%m%d_%H%M).txt"

echo "Security Event Report - $(date)" > "$REPORT_FILE"
echo "-------------------------------------------------" >> "$REPORT_FILE"

echo -e "\nScanning Attempts (e.g., port scans, SSH brute force attempts):" >> "$REPORT_FILE"
grep -Ei "invalid user|failed password|disconnect from|port scan|brute force" "$AUTH_LOG" | grep -v "session opened" >> "$REPORT_FILE"
grep -Ei "Nmap|masscan|hydra|medusa" "$SYSLOG" >> "$REPORT_FILE"

echo -e "\nFailed Login Attempts:" >> "$REPORT_FILE"
grep -Ei "authentication failure|failed to authenticate|incorrect password" "$AUTH_LOG" >> "$REPORT_FILE"

echo -e "\nNew Configuration Changes (e.g., package installations, service restarts):" >> "$REPORT_FILE"
grep -Ei "installed|upgrade|remove|restart|configuration changed|systemctl" "$SYSLOG" | grep -v "systemd-resolved" >> "$REPORT_FILE"
grep -Ei "installed|upgrade|remove" "$KERN_LOG" >> "$REPORT_FILE"

# Define variables for host
REMOTE_HOST="remote_server_ip_or_hostname"

# Execute the scp command with a specific public key for passwordless authentication.
scp -i /home/.DeliveryBot/.ssh/id_rsa.pub   /.reports/security_report_$(date +%Y%m%d_%H%M).txt ReceivingBot@"$REMOTE_HOST":/reports/

' > /usr/local/sbin/LogDelivery.sh

#Replaces IP for the scp command.
sed -i  s/REMOTE_HOST="remote_server_ip_or_hostname"/REMOTE_HOST="$rec_ip""/g /usr/local/sbin/LogDelivery.sh

#Changes cron job to be executable.
chmod +x /usr/local/sbin/LogDelivery.sh

#Adds cronjob to crontab to be run every 5 minutes.
echo "*/5 * * * * DeliveryBot /usr/local/sbin/LogDelivery.sh >> /.reports/scriptfail/fail_$(date +%Y%m%d_%H%M).txt"
