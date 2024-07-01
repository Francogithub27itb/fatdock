#!/bin/bash

# If you're reading this on the GitHub gist, scroll down for instructions.
# If not, go to https://gist.github.com/1071034

set -e

eclipse_bin='#!/bin/bash
if [ -z "$1" ]; then
        scale="1.2"
elif [ "$1" == "hdpi" ]; then
        scale="0.8"
else
        scale="$1"
fi
export ECLIPSE_HOME="/opt/apps/eclipse"
GDK_DPI_SCALE="$scale" $ECLIPSE_HOME/eclipse $2 $3 $4  > /dev/null 2>&1'

eclipse_hdpi_bin='#!/bin/bash
/home/${NB_USER}/.local/bin/eclipse hdpi'

eclipse_desktop="[Desktop Entry]
Encoding=UTF-8
Name=Eclipse
Comment=Eclipse IDE
Exec=/home/$NB_USER/.local/bin/eclipse
Icon=/opt/apps/eclipse/icon.xpm
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true"

base_url="https://www.mirrorservice.org/sites/download.eclipse.org/eclipseMirror/technology/epp/downloads/release/"

echo
#echo "## You need to provide a direct download link ##"
#echo 'You may find direct download links in the next location, for example:'
echo "Latest Release version of Eclipse will be downloaded from: " 
echo "$base_url"
echo

base_web_page=$(curl $base_url)

get_dir(){
#myline=$(echo "$base_web_page" | grep DIR | tail -$1)
#dir=$(echo $myline | cut -d " " -f 5 | cut -d "\"" -f 2)
dir=$(echo "$base_web_page" | grep -oP '(?<=<a href=")\d{4}-\d{2}(?=/">)' | tail -n 1)
}

if [ "$1" != "nodownload" ]; then
	#echo "Enter the URL for the Eclipse gzipped tarball:"
	get_dir
	eclipse_url="${base_url}${dir}/R"
#	read eclipse_url
        echo "eclipse_url=$eclipse_url"
	eclipse_file=${eclipse_url}/eclipse-jee-${dir///}-R-linux-gtk-x86_64.tar.gz
	echo
	echo "Attention: java must be already installed"
	echo 
	echo "Downloading Eclipse..."
	wget -O eclipse.tar.gz "$eclipse_file"        
	echo "Installing eclipse..."
	tar xvf eclipse.tar.gz
	sudo rm -rf /opt/apps/eclipse
	sudo mv eclipse /opt/apps/
	rm -f eclipse.tar.gz
fi

mkdir -p  /home/${NB_USER}/.local/share/applications /home/${NB_USER}/Desktop

touch /home/$NB_USER/.local/bin/eclipse
chmod 755 /home/$NB_USER/.local/bin/eclipse
touch /home/$NB_USER/.local/bin/eclipse-hdpi
chmod 755 /home/$NB_USER/.local/bin/eclipse-hdpi
touch /home/$NB_USER/Desktop/eclipse.desktop
chmod 755 /home/$NB_USER/Desktop/eclipse.desktop
echo -e "$eclipse_bin" | sudo tee /home/$NB_USER/.local/bin/eclipse
echo -e "$eclipse_hdpi_bin" | sudo tee /home/$NB_USER/.local/bin/eclipse-hdpi
echo -e "$eclipse_desktop" | sudo tee /home/$NB_USER/Desktop/eclipse.desktop
rm -f /usr/share/applications/eclipse.desktop /home/${NB_USER}/.local/share/applications/eclipse.desktop
cp /home/$NB_USER/Desktop/eclipse.desktop /home/${NB_USER}/.local/share/applications/eclipse.desktop
echo "Eclipse successfully installed"
exit 0


