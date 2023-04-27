#!/bin/bash

# Script d'installation du logiciel forensique Autopsy pour le système d'exploitation GNU-Linux.
# Ce script fonctionne pour les distributions de type Debian (Ubuntu, Mint, ...)
# Testé sur Linux Mint 21.1 et Autopsy 4.20.0 ave Sleuthkit 4.12.0-1
# Mis en place par Fabrice MASURIER avec l'aide de Nicolas CANOVA (le testeur).

echo "Installation du logiciel Autopsy sur un ordinateur doté d'un système linux X64"
echo "Installation des divers composants"

if [ -d "/home/Desktop" ];then
alias Bureau='Desktop';
echo "Vos dossiers n'ont pas été francisés, Votre dossier Bureau est DESKTOP!";
else echo "Vos dossiers ont été francisés Vous avez un dossier 'Bureau'.";
fi
read -p "Quelle est la dernière version de SleuthKit? Ne donnez que le numéro de version sans le '-1' à la fin : " versionSleuthKit
read -p "Quelle est la dernière version d'Autopsy? Ne donnez, là aussi, que le numéro de version : " versionAutopsy
clear

# Netoyage de versions residuelles

echo "Nettoyage de versions résiduelles."
cd /home/$USER
sudo rm -rf /home/$USER/Autopsy /home/$USER/./autopsy 
sudo rm -rf /home/$USER/Bureau/Autopsy.desktop
sudo apt remove -y sleuthkit-java

# Préparation des dépôts

echo "Préparation des dépôts pour l'installation..."
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
if [[ $? -ne 0 ]]; then
    echo "Echec de mise en route des dépôts" >>/dev/stderr
    exit 1
fi

# Installation des dépendences

echo "Installation des dependences..."
sudo apt update && \
    sudo apt -y install build-essential autoconf libtool automake git zip wget ant \
        libde265-dev libheif-dev \
        libpq-dev \
        testdisk libafflib-dev libewf-dev libvhdi-dev libvmdk-dev \
        libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
clear

# Installation de Netbeans

echo "Installation de Netbeans"
flatpak -y install netbeans
clear

if [[ $? -ne 0 ]]; then
    echo "Echec de l'installation des dependences." >>/dev/stderr
    exit 1
fi

# Installation de Java

echo "Verification de l'installation de Java"
sleep 5
testjava=/usr/lib/jvm/bellsoft*
if [ -e $testjava ] 
then
    echo "Java 8 est déjà installé!"
     sleep 5
else echo "Installation de bellsoft Java 8..."
	workingdir=`pwd`
	mkdir /home/$USER/Autopsy
	chmod 770 -R /home/$USER/Autopsy
	cd /home/$USER/Autopsy
	echo "Installation de java"
	echo "Acquisition des clefs de déchiffrement: "
	wget -q -O - "https://download.bell-sw.com/pki/GPG-KEY-bellsoft" | sudo apt-key add -
	sleep 5
	echo "Téléchargement des sources : "
	echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" | sudo tee /etc/apt/sources.list.d/bellsoft.list
	sleep 5
	echo "Copie depuis le serveur Ubuntu et installation de java 8 ."
	sudo apt-get update
	sudo apt-get install bellsoft-java8-full 
fi
sleep 10
clear

# Java runtime installation

echo "Installation du Runtime..."
sudo apt-get install bellsoft-java8-runtime-full
echo "Prérequis d'Autopsy installés."
#echo "Java path at /usr/lib/jvm/bellsoft-java8-full-amd64: "
export JAVA_HOME=”/usr/lib/jvm/bellsoft-java8-full-amd64″
export JDK_HOME=”${JAVA_HOME}”
export PATH=”${JAVA_HOME}/bin:${PATH}”
sudo echo "JAVA_HOME='/usr/lib/jvm/bellsoft-java8-full-amd64'" >> .bashrc

# Installation de Sleuthkit

workingdir=`pwd`
repauto=/home/$USER/Autopsy
if [ -d $repauto ] 
then
    echo "Le dossier Autopsy existe déjà!"
    sleep 5
else 
    mkdir /home/$USER/Autopsy
    chmod 770 -R /home/$USER/Autopsy
    cd /home/$USER/Autopsy
fi
clear

testsk=/usr/share/java/sleuthkit-$versionSleuthKit.jar
if [ -e $testsk ] 
then
    echo "La bonne version de Sleuthkit est déjà installée!"
    sleep 5
else 
    sudo dpkg --configure -a
    echo "Installation de SleuthKit : "    
    cd /home/$USER/Autopsy 
    wget -q --show-progress "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-"$versionSleuthKit"/sleuthkit-java_"$versionSleuthKit"-1_amd64.deb" /home/$USER/Autopsy
    sleep 5
    sudo dpkg -i /home/$USER/Autopsy/sleuthkit-java_$versionSleuthKit-1_amd64.deb
    sudo apt-get -y install -f
   sleep 5
fi
clear

# Installation d'Autopsy

testauto=/home/$USER/Autopsy/autopsy-$versionAutopsy
if [ -e $testauto ] 
then
    echo "La bonne version d'Autopsy est déjà installée!" 
    echo "Autopsy ne sera pas réinstallé!"
    sleep 5
else 
    cd /home/$USER/Autopsy
    echo "Installation d'Autopsy : "
    wget -q --show-progress "https://github.com/sleuthkit/autopsy/releases/download/autopsy-$versionAutopsy/autopsy-$versionAutopsy.zip" /home/$USER/Autopsy
    cd /home/$USER/Autopsy
    unzip autopsy-$versionAutopsy.zip
    echo "jdkhome=/usr/lib/jvm/bellsoft-java8-full-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JAVA_HOME=/usr/lib/jvm/bellsoft-java8-full-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JDK=/usr/lib/jvm/bellsoft-java8-full-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    
    # Installation 
    jdkhome=$JAVA_PATH        
    chown -R $(whoami)
    cd /home/$USER/Autopsy/autopsy-$versionAutopsy
    chmod u+x unix_setup.sh 
    bash ./unix_setup.sh -j /usr/lib/jvm/bellsoft-java8-full-amd64
    
    # Création de l'icone de démarrage sur le bureau
    clear    
    cd //home/$USER/Autopsy/autopsy-$versionAutopsy
    echo "Effacement des fichiers .zip et .deb"
    rm /home/$USER/Autopsy/autopsy-$versionAutopsy.zip|rm /home/$USER/Autopsy/sleuthkit-java_$versionSleuthKit-1_amd64.deb
    echo "Création d'un lien de démarrage et de son icone sur le bureau"
    /bin/echo "[Desktop Entry]" >/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Version=$versionAutopsy" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Type=Application" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Terminal=false" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Name[fr_FR]=AUTOPSY" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Exec=sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Name=AUTOPSY" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/echo "Icon=/home/$USER/Autopsy/autopsy-$versionAutopsy/icon.ico" >>/home/$USER/Bureau/Autopsy.desktop
    /bin/chmod 711 /home/$USER/Bureau/Autopsy.desktop
    /bin/chmod 777 /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy
    /bin/chmod 777 /home/$USER/Autopsy/autopsy-$versionAutopsy/icon.ico
    echo "Autopsy va démarrer. Une fois que l'application sera en place, elle aura créé ses fichiers de configuration, 
vous devrez alors la fermer, mais laisser le terminal continuer à travailler pour l'installation des modules. 
Lors de la première mise en route, une boîte de dialogue apparait. 
Cette boîte de dialogue demande à l'utilisateur d'utiliser le central repository. 
Il est vivement conseillé d'utiliser cet outil."
    sleep 20
    clear
    echo "Ne fermez pas le temrinal."
    sleep 5
    clear
    echo ok | sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy --nosplash
    
fi

clear

# Installaton des modules

cd /home/$USER/Bureau
testmaster=/home/$USER/.autopsy/dev/python_modules/Skype.py
if [ -e $testmaster ] 
then
    echo "Le dossier des masters est déjà installé!"
    sleep 5
else 
    echo "Installation de plugins Python supplémentaires."
    wget -q --show-progress "https://github.com/markmckinnon/Autopsy-Plugins/archive/master.zip"
    unzip master.zip
    mv Autopsy-Plugins-master/* /home/$USER/.autopsy/dev/python_modules/
    mv Custom_Autopsy_Plugins-master/* /home/$USER/.autopsy/dev/python_modules/

    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Chrome_Passwords/chrome_password_identifier/ChromePasswords.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/GoogleDrive/google_drive/GDrive.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/IE%20Tiles/ie_tiles/IETiles.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/iPhone_Backup_Plist_Analyzer/connected_iphone_analyzer/Iphones.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Skype/skype_analyzer/Skype.py
    wget -q --show-progress https://github.com/sleuthkit/autopsy_addon_modules/blob/master/IngestModules/Windows_Communication_App/windows_communication_App/WindowsCommAppFileIngestModule.py
    
    mv ChromePasswords.py /home/$USER/.autopsy/dev/python_modules/
    mv GDrive.py /home/$USER/.autopsy/dev/python_modules/
    mv IETiles.py /home/$USER/.autopsy/dev/python_modules/
    mv Iphones.py /home/$USER/.autopsy/dev/python_modules/
    mv Skype.py /home/$USER/.autopsy/dev/python_modules/
    mv WindowsCommAppFileIngestModule.py /home/$USER/.autopsy/dev/python_modules/
    rm -R Autopsy-Plugins-master
    rm -R master.zip
fi
clear
cd /home/$USER/Bureau
testmod=/home/$USER/Bureau/ModulesNetBeans/autopsy-ahbm.nbm
if [ -e $testmod ] 
then
    echo "Le dossier des modules netbeans est déjà installé!"
    sleep 5
else 
    mkdir ModulesNetBeans
    chmod 770 ModulesNetBeans
    echo "Les modules fabriqués sous NetBeans se trouvent dans un dossier sur le bureau. Pour les installer, dans Autopsy, allez dans l'onglet Tools, plugins, dans la boite qui s'ouvre choisissez modules téléchargés et séléctionnez les paquets du dossier présent sur le bureau. Les paquets seront alors installés."
    sleep 10
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/sdhash/autopsy-ahbm.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/CopyMove/de-fau-copymoveforgerydetection.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/VirusTotal/org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/Event_Log_Viewer.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/Prefetch_File_Viewer.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/chainsaw.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/cleappanalyzer.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/lnk_file_viewer.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/recentactivity-macos.v02b.nbm
    wget https://github.com/markmckinnon/Autopsy-NBM-Plugins/blob/main/Plugin-Modules/rleappanalyzer.nbm   
    mv autopsy-ahbm.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv de-fau-copymoveforgerydetection.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv Event_Log_Viewer.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv Prefetch_File_Viewer.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv chainsaw.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv cleappanalyzer.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv lnk_file_viewer.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv recentactivity-macos.v02b.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv rleappanalyzer.nbm /home/$USER/Bureau/ModulesNetBeans/   
    rm /home/$USER/Bureau/InstallAutopsy.sh
fi

clear
echo "L'installation est maintenant terminée. Bonne journée!"
sleep 10


