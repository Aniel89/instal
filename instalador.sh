#!/bin/bash
# COLORES
blanco='\033[38;5;231m'
amarillo='\033[38;5;228m'
azul='\033[38;5;14m'
morado='\033[38;5;147m'
azul117='\033[38;5;117m'
moradoL='\033[38;5;54m'
rojo='\033[0;31m'
verde='\033[38;5;148m'
verdeR='\033[38;5;40m'
verde29='\033[38;5;29m'
yellow='\033[0;33m'
rosa='\033[38;5;213m'
melon='\033[38;5;208m'
menta='\033[38;5;84m'
azul123='\033[38;5;123m'
guinda='\033[38;5;161m'
azulR="\033[38;5;18m"
cierre='\033[0m'
color1='\e[031;1m'
color2='\e[34;1m'
color3='\e[0m'
BGVerde="\033[42;37m"
BGRojo="\033[41;37m"
OK="${verde}[OK]${cierre}"
Error="${rojo}[error]${cierre}"
# BARRAS
bar2="\033[1;34m---------------------------------------------------------\033[0m"
bar1="\e[1;30m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"

MyScriptName='Onlycode Panel'

# MI IP
MYIP=$(wget -qO- ipv4.icanhazip.com);

# HoORA LOCAL DE L SERVIDOR 
MyVPS_Time='America/Mexico_City'

function InstAsk(){
 clear
 echo -e "$bar1"
 echo -e "${blanco}Necesitamos capturar algunos datos para su base de datos${cierre}"
 echo -e "${blanco}Puede dejar la opción predeterminada y al presionar enter${cierre}"
 echo -e "$bar1"
 echo -e ""
 echo -e "${azul}Ingrese una contraseña del usuario ${rojo}root ${azul}de MySQL:${cierre}"
 echo -e "$bar2"
 read -p "$(echo -e "${blanco}[Contraseña]: ${cierre}")" -e -i niko DatabasePass
 echo -e ""
 echo -e "$bar1"
 echo -e "${azul}Ingrese un Nombre paa la base de datos${cierre}"
 echo -e "${azul}Por favor, use solo una palabra, sin caracteres especiales que no sean el subrayado (_)${cierre}"
 echo -e "$bar2" 
 read -p "$(echo -e "${blanco}[Nombre]: ${cierre}")" -e -i niko DatabaseName
echo -e ""
 echo -e "$bar1"  
 echo -e "${azul}Ingrese su nombre de dominio${cierre}"
 echo -e "$bar2"
 read -p "$(echo -e "${blanco}[Dominio]: ${cierre}")" -e -i tudominio.com ydomain
 echo -e ""
 echo -e "$bar1"  
 echo -e "${verdeR}Si desea cancelar la instalacion presione CTRL + C de lo contrario continue${cierre}"
 echo -e "$bar2"
 read -n1 -r -p "$(echo -e "${blanco}Pulse cualquier tecla para continuar...${cierre}")"
 echo -e "$bar1"  
}

function InstUpdates(){
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y
 
 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y
 
 # Installing some important machine essentials
 apt-get install nano git wget curl zip unzip tar gzip p7zip-full bc rc openssl cron build-essential expect net-tools screen bzip2 ccrypt lsof -y
 
 # Installing apt-transport-https and needed files
 apt-get install apt-transport-https lsb-release libdbi-perl libecap3 -y
 
 # Installing apache
 apt-get install apache2 -y
 
 # Installing fail2ban
 apt-get install fail2ban -y

 # Trying to remove obsolette packages after installation
 apt-get autoremove -y
 
 # Installing sury repo by pulling its repository inside sources.list file 
 wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
 sleep 2
 echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
 apt-get update
 
 # Installing php 5.6
 apt-get install php5.6 php5.6-fpm php5.6-mcrypt php5.6-sqlite3 php5.6-mbstring php5.6-curl php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-xsl php5.6-xml php5.6-zip php5.6-xmlrpc libapache2-mod-php5.6 -y

}

function InstMysql(){
 # Installing mysql server
 apt-get install mysql-server -y
 
 
 # Set Database Permissions
 chown -R mysql:mysql /var/lib/mysql/
 chmod -R 755 /var/lib/mysql/
 
 # mysql_secure_installation
 so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"n\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"

 #\r
 #Y
 #password
 #password
 #Y
 #n
 #Y
 #Y
 
 # Grant privileges on database to root
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;\r\"
expect \"\";  sleep 3; send \"GRANT ALL PRIVILEGES ON $DatabaseName.* TO 'root'@'localhost';\r\"
expect \"\";  sleep 3; send \"FLUSH PRIVILEGES;\r\"
expect \"\";  sleep 3; send \"EXIT;\r\"
expect eof; ")
echo "$so2"

 # Use MySQL Plugin
 so3=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"use mysql;\r\"
expect \"\";  sleep 3; send \"update user set plugin='' where User='root';\r\"
expect \"\";  sleep 3; send \"flush privileges;\r\"
expect \"\";  sleep 3; send \"EXIT;\r\"
expect eof; ")
echo "$so3"	

 # Set Remote root Login
  so4=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE USER root@'%' IDENTIFIED BY '$DatabasePass';\r\"
expect \"\";  sleep 3; send \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;\r\"
expect \"\";  sleep 3; send \"FLUSH PRIVILEGES;\r\"
expect \"\";  sleep 3; send \"EXIT;\r\"
expect eof; ")
echo "$so4"
}

function InstApache(){
 
 # Add servername on apache conf
 echo "ServerName localhost" >> /etc/apache2/apache2.conf
 
 # modify apache configs
 rm -f /etc/apache2/sites-enabled/000-default.conf
 wget -O /etc/apache2/sites-enabled/dankel.conf "https://www.dropbox.com/s/f71pywsavvoqf63/domain_conf.conf"
 sed -i "s|yourserver|$ydomain|g" /etc/apache2/sites-enabled/dankel.conf 
 
 # Modifying apache modules
 a2dismod mpm_event
 a2enmod php5.6
 a2enmod rewrite
 a2enmod proxy_fcgi setenvif
 a2enconf php5.6-fpm
 ln -sf /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
 systemctl restart apache2
 
 # Add Localhost Domain to Hosts
 echo "127.0.0.1  localhost" >> /etc/hosts
 
 # Setup dir and permissions
 useradd -m panel
 mkdir -p /home/panel/html
 echo "<?php phpinfo() ?>" > /home/panel/html/info.php
 chown -R www-data:www-data /home/panel/html
 chmod -R g+rw /home/panel/html
 #chcon -R -t httpd_sys_rw_content_t /home/panel/html
 
 # Then restart to take effect
 service php5.6-fpm restart
 service apache2 restart
}

function InstPanel(){
 
 # Pull YELLOW Source Code
 wget -O /home/panel/html/ypanel.zip https://www.dropbox.com/s/1oruzfbw0ole9tf/Dankel-new.zip
 sleep 2
 
 # Change dir to Webroot
 cd /home/panel/html
 
 # Deflate panel
 unzip ypanel.zip
 rm -f ypanel.zip
 
 
 # Set permissions
 chown -R www-data:www-data /home/panel/html
 chmod -R g+rw /home/panel/html
 
 # Install XML Parser Perl
 apt-get install libxml-parser-perl -y -f
}

function InstImpSql(){
 # Pull Fixed SQL
 wget -O /home/panel/html/ypanel.sql https://www.dropbox.com/s/135md00wah49lmx/sql_v2ray.sql
 # Import SQL to Database
 mysql -u root -p$DatabasePass $DatabaseName < /home/panel/html/ypanel.sql
 sleep 2
 
 # Change Database /home/panel/html crentials on .env
 sed -i "s|dbpass|$DatabasePass|g" /home/panel/html/includes/db_config.php
 sed -i "s|dbname|$DatabaseName|g" /home/panel/html/includes/db_config.php
 # remplazando la API
 sed -i "s|dbpass|$DatabasePass|g" /home/panel/html/api/v2rayAPI.php
 sed -i "s|dbname|$DatabaseName|g" /home/panel/html/api/v2rayAPI.php
 
 
 # Bind Mysql address to 0.0.0.0
 sleep 5 
echo -e "[mysql]" >> /etc/mysql/my.cnf
 echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf
 service mysql restart
}

function InstPassword(){
  read -p "$(echo -e "${blanco}[Ingresa la Palabra Secreta]: ${cierre}")" -e -i niko pwdo
  echo -e "$bar1"
if test $pwdo == "niko"; then
echo -e "${OK} ${BGVerde} Contraseña Aceptada! ${cierre}"
else
echo -e "${Error} ${BGRojo} Contraseña Incorrecta! ${cierre}"
sleep 2
rm instalador.sh
exit
fi
}

function InstAntiD(){
 # Install Apache2 Anti DDOS and Bruteforce
 apt-get install libapache2-mod-evasive -y
 # Remove duplicate evasive config
 sleep 2
 rm -f /etc/apache2/mods-enabled/evasive.conf
 # Create new evasive configs
cat << EOF > /etc/apache2/mods-enabled/evasive.conf
    <IfModule mod_evasive20.c> 
         DOSHashTableSize 3097 
         DOSPageCount 2 
         DOSSiteCount 50 
         DOSPageInterval 1 
         DOSSiteInterval 1 
         DOSBlockingPeriod 10 
         DOSEmailNotify venturixy@gmail.com
         #DOSSystemCommand "su - someuser -c '/sbin/... %s ...'" 
         DOSLogDir "/var/log/mod_evasive" 
     </IfModule>
EOF
 # Create evasive log directory
 mkdir /var/log/mod_evasive 
 chown -R www-data:www-data /var/log/mod_evasive
 # Set hostame to your domain
 hostnamectl set-hostname $ydomain
 # Restart apache2 service
 systemctl restart apache2
 # Make fail2ban reject malicious requests on apache server
cat << EOF > /etc/fail2ban/jail.d/johnfordtvjail.conf
[apache]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache2/*error.log
maxretry = 3
findtime = 600
ignoreip = 192.168.1.227
 
[apache-noscript]
enabled  = true
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache2/*error.log
maxretry = 3
findtime = 600
ignoreip = 192.168.1.227
 
[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache2/*error.log
maxretry = 2
findtime = 600
ignoreip = 192.168.1.227
 
[apache-badbots]
enabled  = true
port     = http,https
filter   = apache-badbots
logpath  = /var/log/apache2/*error.log
maxretry = 2
findtime = 600
ignoreip = 192.168.1.227
EOF
 # Restart fail2ban service
 service fail2ban restart
}

function InstHistory(){
 # Clear Machine History
 cd
 rm -f /root/.bash_history && history -c
 echo "unset HISTFILE" >> /etc/profile
}

function ScriptMessage(){
  clear
  echo -e "$bar1"
 echo -e " [\e[1;32m$MyScriptName INSTALADOR VPS\e[0m]"
  echo -e "$bar2"
 echo -e "${blanco}[${verdeR}PAYPAL${blanco}]${cierre} ${azul}venturixy@gmail.com${cierre}"
echo -e "$bar1"
 echo -e ""
}
#RCONJOB DE PANEL
echo '*/5 * * * * root cd /home/panel/html/includes/cronjob && php /home/panel/html/includes/cronjob/cronjob_durations_task.php' >> /etc/crontab
echo '*/5 * * * * root cd /home/panel/html/includes/cronjob && php /home/panel/html/includes/cronjob/cronjob_servers.php' >> /etc/crontab
echo '*/10 * * * * root cd /home/panel/html/includes/cronjob && php /home/panel/html/includes/cronjob/cronjob_backup.php' >> /etc/crontab
/etc/init.d/cron reload > /dev/null 2>&1
/etc/init.d/cron restart > /dev/null 2>&1

 # Now check if our machine is in root user, if not, this script exits
 # If you're on sudo user, run `sudo su -` first before running this script
 if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "${Error} ${BGRojo} Este script debe ejecutarse como root, saliendo ... ${cierre}"
 exit 1
fi

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 ScriptMessage
 InstPassword
 sleep 2
 InstAsk
 
 # Update and Install Needed Files
 InstUpdates
 echo -e "${OK} ${BGVerde} Actualizando servidor ... ${cierre}"
 
 # Configure Mysql
 echo -e "${OK} ${BGVerde} Configurando MySQL ... ${cierre}"
 InstMysql
 
 # Configure Apache
 echo -e "${OK} ${BGVerde} Configurando servidor Apache Webserver ... ${cierre}"
 InstApache
 
 # Configure YELLOW
 echo -e "${OK} ${BGVerde} Configurando archivos del panel ... ${cierre}"
 InstPanel
 
 # Configure Anti DDoS
 echo -e "${OK} ${BGVerde} Configuración de Anti-DDoS evasivo y fail2ban ... ${cierre}"
 sleep 2
 InstAntiD
 
 # Configure Database
 echo -e "${OK} ${BGVerde} Configurando Base de Datos ... ${cierre}"
 InstImpSql
 
 # Clear history
 echo -e "${OK} ${BGVerde} Finalizando Instalacion ... ${cierre}"
 InstHistory
 sleep 5
 
 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime

 # Some assistance and startup scripts
 ScriptMessage
 sleep 3
 cd

# Instalando certificado SSL
sudo apt update
sudo apt install snapd
sudo snap install core
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot --apache
sleep 2


# info
clear
echo -e "$bar1" | tee -a log-install.txt
echo -e "${blanco}Onlycode Panel está instalado en http://$MYIP ${cierre}" | tee -a log-install.txt
echo -e "$bar1" | tee -a log-install.txt
echo -e "" | tee -a log-install.txt
echo -e "${amarillo}+Login Details+${cierre}" | tee -a log-install.txt
echo -e "${blanco}Username: ${verdeR}admin${cierre}" | tee -a log-install.txt
echo -e "${blanco}Password: ${verdeR}niko321${cierre}" | tee -a log-install.txt
echo -e "$bar1" | tee -a log-install.txt
echo -e "" | tee -a log-install.txt
echo -e "${blanco}Registro de la instalacion --> /root/log-install.txt ${cierre}" | tee -a log-install.txt
echo -e "$bar1" | tee -a log-install.txt
cd ~/

rm -f instalador.sh
