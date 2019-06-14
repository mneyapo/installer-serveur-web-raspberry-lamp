#!/bin/bash

myUpdate(){
	echo -e "\e[31mmettre à jour la Raspberry Pi\e[0m"
	echo -e "\e[31msudo apt-get update\e[0m"
	sudo apt update
	echo -e "\e[31msudo apt-get upgrade\e[0m"
	sudo apt upgrade
	echo -e "\e[31mupdate\e[0m"
	sudo apt update	
	echo -e "\e[93mFait\e[0m"	
	sleep 5
}

#echo -e "\e[31mmettre à jour firmware\e[0m"
#sudo rpi-update

first_Boot(){
	echo -e "\e[31minstall autocutsel\e[0m"
	sudo apt-get install autocutsel -y
	echo -e "\e[31mDisable onboard WiFi on boot.\e[0m"
	echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
	echo -e "\e[31mDisable Bluetooth boot.\e[0m"
	echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
	echo -e "\e[31mRebooting systeme\e[0m"	
	sleep 5
	sudo reboot
}

Installer_Apache(){
	echo -e "\e[31mInstallation d’Apache\e[0m"
	sudo apt install apache2 -y
	echo -e "\e[32mApache utilise le répertoire /var/www/html comme racine pour votre site\e[0m"
	sudo chown -R pi:www-data /var/www/html/
	sudo chmod -R 770 /var/www/html/
	sleep 5
}

Installer_PHP(){
	echo -e "\e[32mInstallation de PHP sur la Raspberry\e[0m"
	sudo apt install php php-mbstring -y
	echo -e "\e[93mFait\e[0m"
	echo -e "\e[33mVérifier que PHP fonctionne\e[0m"
	echo -e "\e[31msuppression fichier « index.html »\e[0m"	
	sudo rm /var/www/html/index.html
	echo -e "\e[32mcréation fichier « index.php »\e[0m"
	echo "<?php phpinfo(); ?>" > /var/www/html/index.php
	echo -e "\e[33mFait\e[0m"
	sleep 5
}

Installer_MySQL(){
	echo -e "\e[32mInstallation de MySQL sur la Raspberry\e[0m"
	sudo apt install mysql-server php-mysql mysql-client mysql-workbench -y
	echo -e "\e[33mFait\e[0m"
	sleep 5
	# If /root/.my.cnf exists then it won't ask for root password
	if [ -f /root/.my.cnf ]; then
		USER='yapo'
		PASSWORD='pipi'
		RESULT=`mysql -u $USER -p$PASSWORD --skip-column-names -e "SHOW DATABASES LIKE 'rpi'"`
		if [ "$RESULT" == "rpi" ]; then
		    echo -e "\e[31mDatabase exist\e[0m"
	       	    sleep 5
		else
		    echo "Database does not exist"
		    echo "Please enter the NAME of the new database! (example: database1)"
		    read dbname
		    echo "Please enter the database CHARACTER SET! (example: latin1, utf8, ...)"
		    #read charset
		    charset=utf8
		    echo "Creating new database..."
		    sudo mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
		    echo "Database successfully created!"
		    echo "Showing existing databases..."
		    sudo mysql -e "show databases;"
		    echo ""
		    echo "Please enter the NAME of the new database user! (example: user1)"
		    read username
		    echo "Please enter the PASSWORD for the new database user!"
		    read userpass
		    echo "Creating new user..."
		    sudo mysql -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
		    echo "User successfully created!"
		    echo ""
		    echo "Granting ALL privileges on ${dbname} to ${username}!"
		    sudo mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
		    sudo mysql -e "FLUSH PRIVILEGES;"
		    echo "You're good now :)"
		    sleep 5
		fi
		
		
		
	# If /root/.my.cnf doesn't exist then it'll ask for root password	
	else
		rootpasswd=root
		echo "The root user MySQL password! $rootpasswd."
		echo ""
		dbname=rpi
		username=yapo
		userpass=pipi
		RESULT=`mysql -u $username -p$userpass --skip-column-names -e "SHOW DATABASES LIKE 'rpi'"`
		if [ "$RESULT" == "rpi" ]; then
		    echo -e "\e[31mDatabase exist\e[0m"
		    sleep 5
		else
		    echo "The NAME of the new  database! $dbname."
		    charset=utf8
		    echo "the  database CHARACTER SET! $charset."
		    echo "Creating new  database..."
		    sudo mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
		    echo "Database successfully created!"
		    echo "Showing existing databases..."
		    sudo mysql -uroot -p${rootpasswd} -e "show databases;"
		    echo ""
		    echo "The NAME of the new  database user! $username."
		    echo ""
		    echo "The PASSWORD for the new  database user! $userpass."
		    echo "Creating new user..."
		    sudo mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
		    echo "User successfully created!"
		    echo ""
		    echo "Granting ALL privileges on ${dbname} to ${username}!"
		    sudo mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
		    sudo mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
		    sudo mysql -uroot -p${rootpasswd} -e "show databases;"
		    sudo mysql -uroot -p${rootpasswd} -e "USE $dbname;"
		    echo "You're good now :)"
		    sleep 5
		fi
	fi	
	sudo mysql_secure_installation
	echo -e "\e[33mFait\e[0m"
	sudo apt-get install python3-mysqldb
	sleep 60
}
Installer_PHPMyAdmin(){
	echo -e "\e[32mInstallation de PHPMyAdmin\e[0m"
	sudo apt-get install phpmyadmin -y
	echo "Configure Apache"
	sudo chmod o+w /etc/apache2/apache2.conf
	sleep 1
	#echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
	sleep 1
	sudo chmod o-w /etc/apache2/apache2.conf
	cat /etc/apache2/apache2.conf
	sudo phpenmod mysqli
	echo "Restart Apache"
	sudo /etc/init.d/apache2 restart
	sudo systemctl enable apache2
	sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
	echo -e "\e[33mVérifier l’installation de PHPMyAdmin\e[0m"
	echo -e "\e[32m« http://127.0.0.1/phpmyadmin »\e[0m"
	echo -e "\e[33mOk\e[0m"
	sleep 60
}
first_Boot
myUpdate
Installer_Apache
Installer_PHP
Installer_MySQL
Installer_PHPMyAdmin
