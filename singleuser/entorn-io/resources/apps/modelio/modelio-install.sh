#!/bin/bash

set -e

modelio_version=5.3.1
modelio_ver=5.3

modelio_desktop="[Desktop Entry]
Version=1.0
Type=Application
Encoding=UTF-8
Name=Modelio $modelio_ver
Name[fr]=Modelio $modelio_ver
Comment=An Integrated Model-Driven Development Environment (MDA)
Exec=/home/$NB_USER/.local/bin/modelio
Icon=/etc/jupyter/icons/modelio.svg
StartupNotify=true
Terminal=false
Categories=GTK;Development;IDE;
Keywords=UML;Modeler;"

## installation
echo 
echo "Downloading modelio $modelio_version ..."
echo
wget https://github.com/ModelioOpenSource/Modelio/releases/download/v${modelio_version}/modelio-open-source-${modelio_version}-amd64.deb -O ./modelio-open-source_${modelio_version}_amd64.deb

## Old version downloaded from sourceforge
# wget https://sourceforge.net/projects/modeliouml/files/${modelio_version}/modelio-open-source_${modelio_version}_amd64.deb/download -O ./modelio-open-source_${modelio_version}_amd64.deb 

	echo " " 
	echo "Installing modelio $modelio_version ..." 
	echo " " 
	sudo rm -f /etc/modelio-open-source${modelio_ver}/modelio.config 
	export DEBIAN_FRONTEND=noninteractive 
	sudo apt install -y ./modelio-open-source_${modelio_version}_amd64.deb 
	rm -r ./modelio-open-source_${modelio_version}_amd64.deb 
	cp -r /usr/lib/modelio-open-source$modelio_ver /opt/apps/ 
	rm -f /home/$NB_USER/.local/bin/modelio 
	ln -s /opt/apps/modelio-open-source$modelio_ver/modelio.sh /home/$NB_USER/.local/bin/modelio
## configuration
sudo cp /resources/config/modelio.config  /etc/modelio-open-source${modelio_ver}/

## launchers
mkdir -p  /home/${NB_USER}/.local/share/applications /home/${NB_USER}/Desktop
touch /home/$NB_USER/Desktop/modelio.desktop
chmod 755 /home/$NB_USER/Desktop/modelio.desktop
echo -e "$modelio_desktop" | sudo tee /home/$NB_USER/Desktop/modelio.desktop
cp /home/$NB_USER/Desktop/modelio.desktop /home/${NB_USER}/.local/share/applications/modelio.desktop

echo
echo "Modelio $modelio_version successfully installed"
echo
exit 0






