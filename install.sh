#!/bin/bash
clear
if [ "$(whoami)" != 'root' ]; then
	echo 'Please execute this script with root privileges'
	echo ''
	echo 'Press Enter to exit...'
	read ENTER
	exit 0
fi


exec(){
	echo -en "$1...\r"

	$2 2>/tmp/error.log >/dev/null


	if(($? == O)); then

		echo -e "\033[32m [OK] \033[0m $1"
	else
		echo -e "\033[33m [FAILED] \033[0m $1"
		cat /tmp/error.log
	fi

}

PACKET_LIST="geany guake openjdk-7-jre zend-server-php-5.4 pgadmin3 git gitk putty filezilla nfs-common firefox chromium-browser terminator playonlinux mysql-workbench oracle-java7-installer ssh shutter meld"


#Detect System
if [ $(getconf LONG_BIT) = '64' ]; then
	ZEND_STUDIO_URL="http://downloads.zend.com/studio-eclipse/10.5.0/ZendStudio-10.5.0-linux.gtk.x86_64.tar.gz"
	SUBLIME_URL="http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3047_x64.tar.bz2"
	PACKET_LIST="$PACKET_LIST ia32-libs"
	YED_URL="http://www.yworks.com/products/yed/demo/yEd-3.11.1_64-bit_setup.sh"
else
	ZEND_STUDIO_URL="http://downloads.zend.com/studio-eclipse/10.5.0/ZendStudio-10.5.0-linux.gtk.x86.tar.gz"
	SUBLIME_URL="http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3047_x32.tar.bz2"
	YED_URL="http://www.yworks.com/products/yed/demo/yEd-3.11.1_32-bit_setup.sh"
fi
SOAPUI_URL="http://downloads.sourceforge.net/project/soapui/soapui/4.6.0/soapui-4.6.0-linux-bin.tar.gz"
ZEND_SERVER_REPO="deb http://repos.zend.com/zend-server/6.2/deb_ssl1.0 server non-free"
POSTGRES_REPO="deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main"
COMPOSER_URL="http://getcomposer.org/composer.phar"


echo $ZEND_SERVER_REPO > /etc/apt/sources.list.d/zend.list
wget http://repos.zend.com/zend.key -O- 2> /dev/null | apt-key add - >/dev/null
exec "Add Zend repository" " "


#Ajout Depot Postgres

echo $POSTGRES_REPO > /etc/apt/sources.list.d/postgres.list
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- 2> /dev/null | apt-key add - >/dev/null
exec "Add Postgresql repository"

#Ajout Depot Gnome PPA
add-apt-repository -y ppa:gnome3-team/gnome3 > /dev/null 2>&1
exec "Add Gnome3 repository"

#Ajout depot Sun Java
add-apt-repository -y ppa:webupd8team/java > /dev/null 2>&1
exec "Add Sun Java repository"



exec "Update repositories" "apt-get update"
exec "Update Packages" "apt-get dist-upgrade -y"

for PACKET in $PACKET_LIST
do
	exec "Installing $PACKET" "apt-get install -y $PACKET"
done

#Config GIT
git config --global mergetool.keepBackup false
git config --global branch.autosetuprebase always
git config --global pull.rebase true
git config --global core.autocrlf input
git config --global core.safecrlf true


install_zs(){
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

echo -en "Press enter to downlad Zend Studio or s for SKIP \r"
read NEXT
if($NEXT != 's');then
	exec "Installing Zend Studio" "install_zs"
fi

echo -en "Press enter to install Composer or s for SKIP \r"
read NEXT
if($NEXT != 's');then
	exec "Installing Composer" "install_composer"
fi

echo -en "Press enter to downlad Sublime Text 3 or s for SKIP \r"
read NEXT
if($NEXT != 's');then
	exec "Installing Sublime Text 3" "install_sublime"
fi

echo -en "Press enter to downlad yED or s for SKIP \r"
read NEXT
if($NEXT != 's');then
	exec "Installing yED" "install_yed"
fi

echo -en "Press enter to downlad Virtual Box or s for SKIP \r"
read NEXT
if($NEXT != 's');then
	exec "" "install_vbox"
fi
