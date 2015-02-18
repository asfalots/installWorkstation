#!/bin/bash
clear
if [ "$(whoami)" != 'root' ]; then
	echo 'Please execute this script with root privileges'
	echo ''
	echo 'Press Enter to exit...'
	read ENTER
	exit 0
fi


#Detect System
if [ $(getconf LONG_BIT) = '64' ]; then
	ZEND_STUDIO_URL="http://downloads.zend.com/studio-eclipse/12.0.1/ZendStudio-12.0.1-linux.gtk.x86_64.tar.gz"
	SUBLIME_URL="http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x64.tar.bz2"
	PACKET_LIST="$PACKET_LIST ia32-libs"
	YED_URL="http://www.yworks.com/products/yed/demo/yEd-3.11.1_64-bit_setup.sh"
	PGMODELER_URL="http://www.pgmodeler.com.br/releases/0.6.2/pgmodeler-0.6.2-linux64.tar.gz"
else
	ZEND_STUDIO_URL="http://downloads.zend.com/studio-eclipse/11.0.1/ZendStudio-11.0.1-linux.gtk.x86.tar.gz"
	SUBLIME_URL="http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x32.tar.bz2"
	YED_URL="http://www.yworks.com/products/yed/demo/yEd-3.11.1_32-bit_setup.sh"
	PGMODELER_URL="http://www.pgmodeler.com.br/releases/0.6.2/pgmodeler-0.6.2-linux32.tar.gz"
fi
SOAPUI_URL="http://optimate.dl.sourceforge.net/project/soapui/soapui/5.0.0/SoapUI-5.0.0-linux-bin.tar.gz"
ZEND_SERVER_REPO="deb http://repos.zend.com/zend-server/7.0/deb_apache2.4 server non-free"
POSTGRES_REPO="deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main"
COMPOSER_URL="http://getcomposer.org/composer.phar"


FUNCLIST="update_gnome3 install_basic install_zendserver install_postgres install_javasun install_git install_zendstudio install_sublime install_composer install_soapui install_vbox  install_hamster"



exec(){
	echo -en "$1...\r"

	$2 2>/tmp/error.log


	if(($? == O)); then

		echo -e "\033[32m [OK] \033[0m $1"
	else
		echo -e "\033[33m [FAILED] \033[0m $1"
		cat /tmp/error.log
	fi
	clear
}


install_zendserver(){
	echo $ZEND_SERVER_REPO > /etc/apt/sources.list.d/zend.list
	wget http://repos.zend.com/zend.key -O- 2> /dev/null | apt-key add - >/dev/null
	apt-get update
	apt-get install -y zend-server-php-5.4
}

install_postgres(){
	echo $POSTGRES_REPO > /etc/apt/sources.list.d/postgres.list
	wget https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- 2> /dev/null | apt-key add - >/dev/null
	apt-get update
	apt-get install -y postgresql-server-9.3 pgadmin3
}

install_javasun(){
	add-apt-repository -y ppa:webupd8team/java
	apt-get update
	apt-get install -y oracle-java7-installer
}

update_gnome3(){
	add-apt-repository -y ppa:gnome3-team/gnome3
	apt-get update
	apt-get dist-upgrade -y
}

install_git(){

	apt-get install -y "git gitk meld"
	git config --global mergetool.keepBackup false
	git config --global branch.autosetuprebase always
	git config --global pull.rebase true
	git config --global core.autocrlf input
	git config --global core.safecrlf true
}

install_basic(){
	PACKET_LIST="geany guake putty filezilla nfs-common firefox chromium-browser terminator playonlinux ssh shutter"
	for PACKET in $PACKET_LIST
	do
		exec "Installing $PACKET" "apt-get install -y $PACKET"
	done
}

install_zendstudio(){
	cd /tmp
	wget -c $ZEND_STUDIO_URL >/dev/null
	tar -zxvf Zend* >/dev/null
	mv ZendStudio /opt/zendstudio
	ln -s /opt/zendstudio/ZendStudio /usr/bin/zendstudio

cat <<EOF >/usr/share/applications/zendstudio.desktop
[Desktop Entry]
Name=Zend Studio 10
Comment=
TryExec=zendstudio
Exec=zendstudio
Icon=/opt/zendstudio/icon.xpm
Type=Application
Categories=GNOME;GTK;
StartupNotify=true
EOF
	cd -
}


install_sublime(){
	cd /tmp
	wget -c $SUBLIME_URL >/dev/null

	tar xjf sublime* >/dev/null
	mv sublime_text_3/ /opt/sublime_text
	cp /opt/sublime_text/sublime_text.desktop /usr/share/applications/
	rm -f sublime*
	cd -
}

install_composer(){
	cd /tmp
	wget -c $COMPOSER_URL >/dev/null
	chmod +x composer.phar
	mv composer.phar /usr/bin/composer
}

install_soapui(){
	cd /tmp
	wget -c $SOAPUI_URL >/dev/null

	tar zxvf soapui* >/dev/null
	mv soapui-4.6.0/ /opt/soapui >/dev/null
	ln -s /usr/opt/soapui/bin/soapui.sh /usr/bin/soapui >/dev/null
	rm -f soapui*
cat <<EOF >/usr/share/applications/soapui.desktop
[Desktop Entry]
Name=Soapui
Comment=
TryExec=soapui
Exec=soapui
Icon=/usr/opt/soapui/bin/soapui32.png
Type=Application
Categories=GNOME;GTK;
StartupNotify=true
EOF
	cd -
}

install_vbox(){
	cd /tmp
	wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -
	echo "deb http://download.virtualbox.org/virtualbox/debian `lsb_release -sc` contrib" | sudo tee -a /etc/apt/sources.list.d/virtualbox.list
	exec "Update repositories" "apt-get update"
	exec "Installing virtualbox" "apt-get install virtualbox-4.3"
}

install_yed(){
	cd /tmp
	wget -c --output-document=yed.sh $YED_URL >/dev/null
	chmod +x yed.sh
	./yed.sh
}

install_pgmodeler(){
	apt-get install -y qt5-default
	cd /tmp
	wget -c $PGMODELER_URL
	tar zxvf pgmodeler*
	find /tmp -type d -name "pgmod*" -exec mv {} /opt/pgmodeler \;
	mv /tmp/pgmodeler.vars /etc/profile.d/pgmodeler.sh
	chmod +x /etc/profile.d/pgmodeler.sh

cat <<EOF >/usr/share/applications/pgmodeler.desktop
[Desktop Entry]
Name=PGModeler
Comment=
TryExec=pgmodeler
Exec=pgmodeler
Icon=/opt/pgmodeler/conf/pgmodeler_logo.png
Type=Application
Categories=GNOME;GTK;
StartupNotify=true
EOF

}

install_hamster(){
	cd /tmp
	apt-get install -y gettext intltool python-gconf
	git clone https://github.com/projecthamster/hamster.git
	cd hamster
	./waf configure build --prefix=/usr
	./waf install
	cd -
}


fullInstall(){
	for FUNC in $FUNCLIST
	do
		exec $FUNC $FUNC
	done
}

menu(){
	COUNTER=0
	for FUNC in $FUNCLIST
	do
	    echo [$COUNTER] $FUNC
	    COUNTER=$[COUNTER+1]
	done
	list=( $FUNCLIST)

	read CHOICE
	clear
	exec ${list[$CHOICE]} ${list[$CHOICE]}
	menu
}


clear
echo "Please choice what you want to do:"
echo "[0] Full Install"
echo "[1] Partial Install"
read SELECT

case $SELECT in
	0)
	clear
	fullInstall
	;;

	1)
	clear
	menu
	;;
esac
