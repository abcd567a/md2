#!/bin/bash

INSTALL_FOLDER=/usr/share/md2

echo "Creating folder md2"
sudo mkdir ${INSTALL_FOLDER}
echo "Downloading modeSDeco2 file from Google Drive"
sudo wget -O ${INSTALL_FOLDER}/modesdeco2_rpi2-3_deb9_20180729.tgz "https://drive.google.com/uc?export=download&id=1WhheW-I4_1sb3VUXa9bcs8XEkh9fn_Lh" 


echo "Unzipping downloaded file"
sudo tar xvzf ${INSTALL_FOLDER}/modesdeco2_rpi2-3_deb9_20180729.tgz -C ${INSTALL_FOLDER}

echo "Creating symlink to modesmixer2 binary in folder /usr/bin/ "
sudo ln -s ${INSTALL_FOLDER}/modesdeco2 /usr/bin/modesdeco2

echo "Creating startup script file md2-start.sh"
SCRIPT_FILE=${INSTALL_FOLDER}/md2-start.sh
sudo touch ${SCRIPT_FILE}
sudo chmod 777 ${SCRIPT_FILE}
echo "Writing code to startup script file md2-start.sh"
/bin/cat <<EOM >${SCRIPT_FILE}
#!/bin/sh
CONFIG=""
while read -r line; do CONFIG="\${CONFIG} \$line"; done < ${INSTALL_FOLDER}/md2.conf
${INSTALL_FOLDER}/modesdeco2 \${CONFIG}
EOM
sudo chmod +x ${SCRIPT_FILE}

echo "Creating config file md2.conf"
CONFIG_FILE=${INSTALL_FOLDER}/md2.conf
sudo touch ${CONFIG_FILE}
sudo chmod 777 ${CONFIG_FILE}
echo "Writing code to config file md2.conf"
/bin/cat <<EOM >${CONFIG_FILE}
--beast 30005
--msg 30003
--web 8585

EOM
sudo chmod 644 ${CONFIG_FILE}

echo "Creating Service file md2.service"
SERVICE_FILE=/lib/systemd/system/md2.service
sudo touch ${SERVICE_FILE}
sudo chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
# modesdeco2 service for systemd
[Unit]
Description=ModeSDeco2
Wants=network.target
After=network.target
[Service]
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

sudo chmod 744 ${SERVICE_FILE}
sudo systemctl enable md2
sudo systemctl start md2

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


