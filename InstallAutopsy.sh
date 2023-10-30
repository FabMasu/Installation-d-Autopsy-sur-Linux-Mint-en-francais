#!/bin/bash

# Installation script for forensic software Autopsy GNU-Linux OS.
# This script wroks for Debian type distributions (Ubuntu, Mint, ...)
# Tested on Linux Mint 21.1 and Autopsy 4.20.0 with Sleuthkit 4.12.0-1
# By Fabrice MASURIER with the help of Nicolas CANOVA (le testeur) et quelques Ntuches volontaires.

echo "Installation d'Autopsy sur un système de type linux X64"
echo "Installation des dépendences"

if [ -d "/home/Desktop" ];then
alias Bureau='Desktop';
echo "Your DESKTOP seems to be the english way!";
else echo "Vos dossiers ont été francisés Vous avez un dossier 'Bureau'.";
fi
read -p "Quelle est la version de Sleuthkit? Donnez juste le numéro de version sans le '-1' à la fin (ex:4.12.0) : " versionSleuthKit
read -p "Quelle est la version de Autopsy? Ne donnez également que le numéro de version (ex:4.20.0) : " versionAutopsy
clear

# removing older versions

echo "Retrait des anciennes versions."
cd /home/$USER
sudo rm -rf /home/$USER/Autopsy /home/$USER/./autopsy 
sudo rm -rf /home/$USER/Bureau/Autopsy.desktop
sudo apt remove -y sleuthkit-java

# Preparing sources

echo "Preparation des sources..."
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
if [[ $? -ne 0 ]]; then
    echo "Echec de préparation des sources." >>/dev/stderr
    exit 1
fi

# Prerequistes installation

echo "Installation des prérequis..."
sudo apt update && \
    sudo apt -y install \
        openjdk-17-jdk openjdk-17-jre \
        build-essential autoconf libtool automake git zip wget ant \
        libde265-dev libheif-dev \
        libpq-dev \
        testdisk libafflib-dev libewf-dev libvhdi-dev libvmdk-dev \
        libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x \
        gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio flatpak
if [[ $? -ne 0 ]]; then
    echo "Echec de l'installation des dépendences nécessaires" >>/dev/stderr
    exit 1
fi
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo



clear
echo "Installation de Netbeans..."
flatpak -y install netbeans
clear

if [[ $? -ne 0 ]]; then
    echo "Echec de l'installation des prérequis." >>/dev/stderr
    exit 1
fi

# Java installation
echo "Installation de Java 17: "
update-java-alternatives -l | grep java-1.17
sleep 5

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export JDK_HOME=”${JAVA_HOME}”
export PATH=”${JAVA_HOME}/bin:${PATH}”
sudo echo "JAVA_HOME='/usr/lib/jvm/java-17-openjdk-amd64'" >> .bashrc


export PATH=$JAVA_HOME/bin:$PATH

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
    echo "la même version de Sleuthkit est déjà installée!"
    echo "Sleuthkit ne sera pas réinstallé!"
    sleep 5
else 
    sudo dpkg --configure -a
    echo "SleuthKit installation : "    
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
    echo "la même version d'Autopsy est déjà installée!" 
    echo "Autopsy ne sera pas réinstallé!"
    sleep 5
else 
    cd /home/$USER/Autopsy
    echo "Installation d'Autopsy : "
    wget -q --show-progress "https://github.com/sleuthkit/autopsy/releases/download/autopsy-$versionAutopsy/autopsy-$versionAutopsy.zip" /home/$USER/Autopsy
    cd /home/$USER/Autopsy
    unzip autopsy-$versionAutopsy.zip
    echo "jdkhome=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    echo "JDK=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/Autopsy/autopsy-$versionAutopsy/etc/autopsy.conf
    
    # Installation 
    jdkhome=$JAVA_PATH        
    chown -R $(whoami)
    cd /home/$USER/Autopsy/autopsy-$versionAutopsy
    chmod u+x unix_setup.sh 
    bash ./unix_setup.sh -j /usr/lib/jvm/java-17-openjdk-amd64 -n autopsy
    
    # Icon creation on the desk
    clear    
    cd //home/$USER/Autopsy/autopsy-$versionAutopsy
    echo "Retrait des .zip et .deb"
    rm /home/$USER/Autopsy/autopsy-$versionAutopsy.zip|rm /home/$USER/Autopsy/sleuthkit-java_$versionSleuthKit-1_amd64.deb
    echo "Creation d'un lien et d'une icone sur le bureau"
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
    echo "Autopsy va démarrer. Une fois fait, Il va créer ses propres dossiers de configuration,
vous pouvez le fermer, mais laissez le terminal continuer, il installera les modules supplémentaires. 
Au départ, une boîte de dialogue vous demendera d'utiliser le Central repository. Cliquez sur OK."
    sleep 20
    clear
    echo "Fermez l'application, ne fermez pas le terminal il se fermera tout seul"
    echo ok | sh /home/$USER/Autopsy/autopsy-$versionAutopsy/bin/autopsy --nosplash
    
fi

clear

# Modules installation

cd /home/$USER/Bureau
testmaster=/home/$USER/.autopsy/dev/python_modules/Skype.py
if [ -e $testmaster ] 
then
    echo "Masters folder est déjà installé!"
    sleep 5
else 
    echo "Installation des plugins Python."
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
    echo "Les modules Netbeans sont déjà installés!"
    sleep 5
else 
    mkdir ModulesNetBeans
    chmod 770 ModulesNetBeans
    echo "Les modules Netbeans sont sur le bureau. Pour les installer dans Autopsy, allez dans 'Tools', 'plugins', et dans la boîte de dialogue, choisissez 'Downloaded modules' et selectionnez le dossier sur le bureau. Les modules seront installés."
    sleep 10
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/sdhash/autopsy-ahbm.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/CopyMove/de-fau-copymoveforgerydetection.nbm
    wget https://github.com/sleuthkit/autopsy_addon_modules/raw/master/IngestModules/VirusTotal/org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm
    mv autopsy-ahbm.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv de-fau-copymoveforgerydetection.nbm /home/$USER/Bureau/ModulesNetBeans/
    mv org-sleuthkit-autopsy-modules-virustotalonlinecheck.nbm /home/$USER/Bureau/ModulesNetBeans/
    rm /home/$USER/Bureau/InstallAutopsy.sh
fi

clear
echo "L'installation est maintenant terminée. Passez une bonne journée!"
sleep 10



