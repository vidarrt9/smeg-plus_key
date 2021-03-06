#!/bin/bash

if [ "`whoami`" != "root" ];
then
echo "This script needs to be run as root. Please use sudo."
exit 1
fi

if [ "`grep ^dtoverlay=dwc2 /boot/config.txt`" = "" ]; then
echo dtoverlay=dwc2 >> /boot/config.txt
fi

echo "Installing USB gadget script..."
# Installing as a system service to enable it on boot
mkdir /usr/lib/systemd/system
cp resources/myusbgadget /usr/local/bin/
cp resources/usbgadget_enable.sh /usr/local/bin/
cp resources/usbgadget_disable.sh /usr/local/bin/
cp resources/bridge_enable.sh /usr/local/bin/
cp resources/feed_storage.sh /usr/local/bin/
chmod +x /usr/local/bin/myusbgadget
chmod +x /usr/local/bin/usbgadget_enable.sh
chmod +x /usr/local/bin/usbgadget_disable.sh
chmod +x /usr/local/bin/bridge_enable.sh
chmod +x /usr/local/bin/feed_storage.sh

cp resources/myusbgadget.service /usr/lib/systemd/system/
cp resources/feed_storage.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable myusbgadget.service
systemctl enable feed_storage.service

echo "Installing network related files..."
# USB gadget configuration file
cat resources/dhcpcd.conf >> /etc/dhcpcd.conf
#cp resources/usb0 /etc/network/interfaces.d/

echo "Setting up the read-only filesystem..."
# We need to setup filesystems as readonly because the RPi will be shut down without notice
cp /etc/fstab /etc/fstab.bak
sed 's/^\(PARTUUID.*defaults\)/\1,ro/g' -i /etc/fstab
sed 's/\(\/boot.*ro\)/\1,noauto/' -i /etc/fstab
# Add some folders as tmpfs (logs, tmp...)
cat resources/fstab.tmp >> /etc/fstab
# this remount script can be called to mount root filesystem as read-write again
cp resources/remount /usr/bin/remount
chmod +x /usr/bin/remount
mv /etc/resolv.conf /tmp/resolv.conf
ln -s /tmp/resolv.conf /etc/resolv.conf

echo "Installation is done! One last step, create /etc/feed_storage.config with :"
echo "HOST=...."
echo "PORT=...."
echo "USER=...."
echo 
echo "Next, you can reboot to apply the configuration."
