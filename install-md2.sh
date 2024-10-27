#!/bin/bash
VERSION=modesdeco2_rpi2-3_deb9_20180729
INSTALL_FOLDER=/usr/share/md2
echo "Creating install folder md2"
mkdir ${INSTALL_FOLDER}

echo -e "\e[1;32m...ADDING ARCHITECTURE armhf ...\e[39m"
sleep 2
dpkg --add-architecture armhf
echo -e "\e[1;32m...UPDATING ... \e[39m"
sleep 2
apt update
echo -e "\e[1;32m...INSTALLING DEPENDENCY PACKAGES ... \e[39m"
echo -e "\e[1;32m...INSTALLING DEPENDENCY 1 of 3 (libssl1.1:armhf) ... \e[39m"
sleep 2
apt install -y libssl1.1:armhf

if [[ ! `dpkg-query -W libssl1.1:armhf` ]]; then
  wget -O ${INSTALL_FOLDER}/libssl1.1_1.1.1w-0+deb11u1_armhf.deb "http://http.us.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.1w-0+deb11u1_armhf.deb";
  apt install -y ${INSTALL_FOLDER}/libssl1.1_1.1.1w-0+deb11u1_armhf.deb;
fi

echo -e "\e[1;32m...INSTALLING DEPENDENCY 2 of 3 (libstdc++6:armhf) ... \e[39m"
sleep 2
apt install -y libstdc++6:armhf
echo -e "\e[1;32m...INSTALLING DEPENDENCY 3 of 3 (libudev-dev:armhf) ... \e[39m"
sleep 2
apt install -y libudev-dev:armhf

echo "Downloading modeSDeco2 file from Github"
wget -O ${INSTALL_FOLDER}/${VERSION}.tgz "https://github.com/abcd567a/md2/releases/download/v1/${VERSION}.tgz" 

echo "Unzipping downloaded file"
tar xvzf ${INSTALL_FOLDER}/${VERSION}.tgz -C ${INSTALL_FOLDER}

echo "Creating symlink to modesdeco2 binary in folder /usr/bin/ "
ln -s ${INSTALL_FOLDER}/modesdeco2 /usr/bin/modesdeco2

echo "Downloading & installing rtl-sdr.rules file from Github ..."
wget -O /etc/udev/rules.d/rtl-sdr.rules "https://raw.githubusercontent.com/abcd567a/md2/refs/heads/master/rtl-sdr.rules"

echo "Creating startup script file md2-start.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/md2-start.sh
touch ${SCRIPT_FILE}
chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file md2-start.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/md2.conf
${INSTALL_FOLDER}/modesdeco2 \${CONFIG}
EOM
chmod +x ${SCRIPT_FILE}

echo "Creating config file md2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/md2.conf
touch ${CONFIG_FILE}
chmod 777 ${CONFIG_FILE}
echo "Writing code to config file md2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--beast 30005
--msg 30003
--avr 30002
--web 8585

EOM
chmod 644 ${CONFIG_FILE}

echo "Creating User md2 to run modesdeco2"
useradd --system md2
usermod -a -G plugdev md2

echo "Assigning ownership of install folder to user md2"
chown md2:md2 -R ${INSTALL_FOLDER}

echo "Creating Service file md2.service"
SERVICE_FILE=/lib/systemd/system/md2.service
touch ${SERVICE_FILE}
chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# modesdeco2 service for systemd
[Unit]
Description=ModeSDeco2
Wants=network.target
After=network.target
[Service]
User=md2
RuntimeDirectory=modesdeco2
RuntimeDirectoryMode=0755
ExecStart=/bin/bash ${INSTALL_FOLDER}/md2-start.sh
SyslogIdentifier=modesdeco2
Type=simple
Restart=on-failure
RestartSec=30
RestartPreventExitStatus=64
Nice=-5
[Install]
WantedBy=default.target

EOM

chmod 744 ${SERVICE_FILE}
systemctl enable md2

echo "Creating blacklist-rtl-sdr file..."
BLACKLIST_FILE=/etc/modprobe.d/blacklist-rtl-sdr.conf
touch ${BLACKLIST_FILE}
chmod 777 ${BLACKLIST_FILE}
echo "Writing code to blacklist file"
/bin/cat <<EOM >${BLACKLIST_FILE}
blacklist rtl2832
blacklist dvb_usb_rtl28xxu
blacklist dvb_usb_v2,rtl2832
EOM
chmod 644 ${BLACKLIST_FILE}

echo "Unloading kernel drivers for rtl-sdr..."
rmmod rtl2832 dvb_usb_rtl28xxu dvb_usb_v2,rtl2832

echo "Starting  ModeSDeco2 ..."
systemctl start md2

echo " "
echo " "
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mPLEASE DO FOLLOWING:\e[39m"
echo -e "\e[32m=======================\e[39m"
echo ""
echo -e "\e[32m(1) In your browser, go to Web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8585 \e[39m"
echo " "
echo -e "\e[33m(2) Open file md2.conf by following command:\e[39m"
echo -e "\e[39m     sudo nano "${INSTALL_FOLDER}"/md2.conf \e[39m"
echo ""
echo -e "\e[33mAdd following line:\e[39m"
echo -e "\e[39m     --location xx.xxxx:yy.yyyy  \e[39m"
echo ""
echo -e "\e[33m(Replace xx.xxxx and yy.yyyy \e[39m"
echo -e "\e[33mby your actual latitude and longitude) \e[39m"
echo -e "\e[33mSave (Ctrl+o) and Close (Ctrl+x) file md2.conf \e[39m"
echo -e "\e[33mthen restart md2 by following command:\e[39m"
echo -e "\e[39m     sudo systemctl restart md2 \e[39m"
echo " "
echo -e "\e[32mTo see status\e[39m sudo systemctl status md2"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart md2"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop md2"
echo ""
echo -e "\e[1;31mIf status shows \"Error: sdr_open(): Device or resource busy\", then \e[39m"
echo -e "\e[1;32m    (1) Unplug and re-plug the Dongle \e[39m"
echo -e "\e[1;32m    (2) REBOOT Pi \e[39m"
echo ""

