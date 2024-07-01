#!/bin/bash

echo
echo "Welcome to Project Pencil installer."
echo
echo "## You must provide a download link from: ##"
echo "   https://pencil.evolus.vn/Nightly.html"
echo
echo "Enter the URL for the Pencil Project nightly deb package:"
read pencil_url
echo

dir_name=pencil
file=pencil.deb
version=v3

pencil_bin="#!/bin/sh
export PENCIL_HOME='/opt/apps/$dir_name'
\$PENCIL_HOME/pencil \$* > /dev/null 2>&1"


pencil_desktop="[Desktop Entry]
Name=Pencil
Comment=Pencil Project
Version=$version
Type=Application
Categories=Graphics
MimeType=text/plain;
Exec=/opt/apps/$dir_name/pencil
Terminal=false
StartupNotify=true
Icon=/opt/apps/$dir_name/pencil.png"


echo
echo "Installing Pencil Project ..."
echo

cd /tmp
if [ ! -f "/tmp/$file" ]; then
   wget -O $file $pencil_url
fi

sudo apt install -y ./$file


sudo rm -f ./$file

if [ -L "/usr/bin/pencil" ]; then
      sudo rm -f /usr/bin/pencil
fi

if [ -d "/opt/apps/$dir_name" ]; then
      rm -f /opt/apps/$dir_name
fi

sudo mv /opt/pencil* /opt/apps/$dir_name

sudo chown $NB_USER:$NB_GID -R /opt/apps/$dir_name

sudo ln -s /opt/apps/$dir_name/pencil /usr/bin/pencil

sudo cp /usr/share/applications/pencil.png /opt/apps/$dir_name/pencil.png

mkdir -p  /home/${NB_USER}/.local/share/applications /home/${NB_USER}/Desktop

touch /home/$NB_USER/.local/bin/pencil
chmod 755 /home/$NB_USER/.local/bin/pencil
touch /home/$NB_USER/Desktop/pencil.desktop
chmod 755 /home/$NB_USER/Desktop/pencil.desktop
echo -e "$pencil_bin" | sudo tee /home/$NB_USER/.local/bin/pencil
echo -e "$pencil_desktop" | sudo tee /home/$NB_USER/Desktop/pencil.desktop
sudo rm -f /usr/share/applications/pencil.desktop /home/${NB_USER}/.local/share/applications/pencil.desktop
cp /home/$NB_USER/Desktop/pencil.desktop /home/${NB_USER}/.local/share/applications/pencil.desktop

echo
echo "Project Pencil successfully installed !"
echo
exit 0

