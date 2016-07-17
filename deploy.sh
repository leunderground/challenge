#!/bin/bash
#some vars
ROOTPASS=ledbapsswd#3
DBNAME=wpdb
DBUSER=wpuser
DBUSERPS=mywppswd
DBHOST=localhost
WPURL=challenge

#some dependecies
aptitude update
aptitude -y install mysql-server
aptitude -y install expect
aptitude -y install apache2

#securing the mysql installation
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"New password:\"
send \"ledbapsswd#3\r\"
expect \"Re-enter new password:\"
send \"ledbapsswd#3\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
#kudos https://gist.github.com/Mins/4602864

#echo "$SECURE_MYSQL"

#WP DB
echo "CREATE DATABASE $DBNAME;" | mysql -u root -p$ROOTPASS
echo "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBUSERPS';" | mysql -u root -p$ROOTPASS
echo "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';" | mysql -u root -p$ROOTPASS
echo "FLUSH PRIVILEGES;" | mysql -u root -p$ROOTPASS
echo "insert into wp_users (id, user_login, user_pass, user_nicename, user_email, user_url, user_registered, user_activation_key, user_status, display_name) values (1, 'r4z', \"$P$BFI29MymAhWrC./xhfuk3jmI6QgY/M0\", 'r4z', 'r4z@openmailbox.org', '', '2016-07-16 19:35:01', '', 0, 'r4z')" | mysql -u$DBUSER $DBNAME -pmywppswd #change this according to your needs
echo "New MySQL database is successfully created"

#cleaning and adding more dependencies
aptitude -y purge expect
aptitude -y install php5 libapache2-mod-php5 libapache2-mod-auth-mysql php5-mysql

# getting, unpacking and configurin wp
chown www-data:www-data /var/www
cd /var/www/html
mv /var/www/index.html /var/www/index.html.orig
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www/html --transform s/wordpress/$WPURL/
chown www-data: -R /var/www/html/$WPURL && cd /var/www/html/$WPURL
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php
mkdir uploads
sed -i "s/database_name_here/$DBNAME/;s/username_here/$DBUSER/;s/password_here/$DBUSERPS/" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php


# Create Apache virtual host
echo "
ServerName $WPURL
DocumentRoot /var/www/html/$WPURL
DirectoryIndex index.php

Options FollowSymLinks
AllowOverride All

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
" > /etc/apache2/sites-available/$WPURL

# Enable the site
a2ensite $WPURL
service apache2 restart

WPVER=$(grep "wp_version = " /var/www/html/$WPURL/wp-includes/version.php |awk -F\' '{print $2}')
echo -e "\n[+] WordPress version $WPVER is successfully installed!"

#IRC:
adduser ircd
adduser ircd sudo
su ircd
cd ~
sudo apt-get update
aptitude -y install libssl-dev openssl
aptitude -y install libcurl4-openssl-dev zlib1g zlib1g-dev zlibc libgcrypt11 libgcrypt11-dev
wget --no-check-certificate http://unrealircd.org/downloads/Unreal3.2.10.4.tar.gz
tar xzvf Unreal3.2.10.4.tar.gz
cd Unreal3.2.10.4
./Config

#ugly way to automate the edit of the .conf file but it was a lot of fields
#and i prefer to save that time instead of doing regex all day long :D
echo '
include "help.conf";
include "badwords.channel.conf";
include "badwords.message.conf"
include "badwords.quit.conf";
include "spamfilter.conf";
loadmodule "src/modules/commands.so";
loadmodule "src/modules/cloak.so";



me
{
	name "irc.safe2choose.org";
	info "luperciomx Server";
	numeric 1;
};



admin {
	"r4z";
	"raz lupercio";
	"r4z@openmailbox.org";
};

class clients
{
	pingfreq 90;
	maxclients 500;
	sendq 100000;
	recvq 8000;
};
class servers
{
	pingfreq 90;
	maxclients 10;
	sendq 1000000;
	connfreq 100;
};
allow {
	ip             *@*;
	hostname       *@*;
	class           clients;
	maxperip 5;
};
allow {
	ip             *@255.255.255.255;
	hostname       *@*.passworded.ugly.people;
	class           clients;
	password "f00Ness";
	maxperip 1;
};
allow channel {
	channel "#WarezSucks";
	class "clients";
};
oper r4z {
	class           clients;
	from {
		userhost *@*;
	};
	password "lepassword";
	flags
	{
		netadmin;
		can_zline;
		can_gzline;
		can_gkline;
		global;
	};
};
listen         *:6697
{
	options
	{
		ssl;
		clientsonly;
	};
};

listen         *:8067;
listen         *:6667;
ulines {
	services.safe2choose.org;
	stats.safe2choose.org;
};

drpass {
	restart "take-a-break";
	die "cierra-el-changarro";
};

log "ircd.log" {
	maxsize 2097152;
	flags {
		oper;
		connects;
		server-connects;
		kills;
		errors;
		sadmin-commands;
		chg-commands;
		oper-override;
		spamfilter;
	};
};

alias NickServ { type services; };
alias ChanServ { type services; };
alias OperServ { type services; };
alias HelpServ { type services; };
alias StatServ { type stats; };

alias "services" {
	format "^#" {
		target "chanserv";
		type services;
		parameters "%1-";
	};
	format "^[^#]" {
		target "nickserv";
		type services;
		parameters "%1-";
	};
	type command;
};

alias "identify" {
	format "^#" {
		target "chanserv";
		type services;
		parameters "IDENTIFY %1-";
	};
	format "^[^#]" {
		target "nickserv";
		type services;
		parameters "IDENTIFY %1-";
	};
	type command;
};
alias "glinebot" {
	format ".+" {
		command "gline";
		type real;
		parameters "%1 2d Bots are not allowed on this server, please read the faq at http://www.example.com/faq/123";
	};
	type command;
};

files
{

};

tld {
	mask *@*.fr;
	motd "ircd.motd";
	rules "ircd.rules";
};

set {
	network-name 		"s2cNet";
	default-server 		"irc.safe2choose.org";
	services-server 	"services.safe2choose.org";
	stats-server 		"stats.safe2choose.org";
	help-channel 		"#s2cHelpNet";
	hiddenhost-prefix 		"s2c";

	cloak-keys {
		"brespumuste6ewRbrespumuste6e";
		"fUkAChekEswu6edfUkAChekEswu6";
		"4aFachehetawedR4aFachehetawe";
	};
	hosts {
			local 		"locop.safe2choose.org";
			global 		"locop.safe2choose.org";
			coadmin 		"coadmin.safe2choose.org";
			admin 		"admin.safe2choose.org";
		servicesadmin	 	"csops.safe2choose.org";
		netadmin 		"netadmin.safe2choose.org";
		host-on-oper-up "no";
	};
};

set {
	kline-address "r4z@openmailbox.org";
	modes-on-connect "+ixw";
	modes-on-oper	 "+xwgs";
	oper-auto-join "#opers";
	options {
		hide-ulines;
		show-connect-info;
	};

	maxchannelsperuser 10;
	anti-spam-quit-message-time 10s;
	oper-only-stats "okfGsMRUEelLCXzdD";

	throttle {
		connections 3;
		period 60s;
	};

	anti-flood {
		nick-flood 3:60;
	};

	spamfilter {
		ban-time 1d;
		ban-reason "Spam/Advertising";
		virus-help-channel "#help";
	};
};

' > ~/Unreal3.2.10.4/unrealircd.conf

touch ~/Unreal3.2.10.4/ircd.log
touch ~/Unreal3.2.10.4/ircd.rules
touch ~/Unreal3.2.10.4/ircd.motd
make

./unreal start
