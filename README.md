# md2
### ModeSDeco2 installation script for RPi 2/3/4 and Raspbian Stretch/Buster

</br>

Copy-paste following command in SSH console and press Enter key. The script will install and configure modesdecoder2. </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/md2/master/install-md2.sh)" `</br></br>
After script finishes, it displays following message
```
=======================
INSTALLATION COMPLETED
=======================
PLEASE DO FOLLOWING:
Open file md2.conf for editing by following command:
sudo nano /usr/share/md2/md2.conf
replace xx.xxxx and yy.yyyy
by your actual latitude and longitude
in following line:
--location xx.xxxx:yy.yyyy

Web interface at http://ip-of-pi:8787

To see status sudo systemctl status md2
To restart    sudo systemctl restart md2
To stop       sudo systemctl stop md2
```

### CONFIGURATION </br>
The configuration file can be edited by following command; </br>
`sudo nano /usr/share/md2/md2.conf ` </br></br>
**Default contents of config file**</br>
This can be changed by editing config file</br>
You can add extra arguments, one per line starting with `--` </br>

```
--beast 30005
--msg 30003
--web 8787
--location xx.xxxx:yy.yyyy
```
