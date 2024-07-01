#!/bin/bash

scripts=scripts

export user=$NB_USER

APPDIR=/opt/apps/jetbrains-toolbox

toolbox_desktop="[Desktop Entry]
Version=1.0
Type=Application
Encoding=UTF-8
Name=Jetbrains Toolbox
Comment=Jetbrains Toolbox
Exec=env APPDIR=$APPDIR /home/$NB_USER/.local/bin/jetbrains-toolbox
Icon=/etc/jupyter/icons/toolbox.svg
StartupNotify=true
Terminal=false
Categories=GTK;Development;IDE;
Keywords=IDE;"

toolbox_script='#!/bin/sh
export APPDIR=/opt/apps/jetbrains-toolbox
$APPDIR/jetbrains-toolbox
'

toolbox_settings='{
    "install_location": "/opt/apps/jetbrains-toolbox",
    "shell_scripts": {
        "location": "/home/NB_USER/.local/bin"
    },
    "ui": {
        "theme": "light"
    },
    "tools": {
        "localize_tools": true
    }
}'


[ $(id -u) != "0" ] && exec sudo -E "$0" "$@"
echo -e " \e[94mInstalling Jetbrains Toolbox\e[39m"
echo ""

function getLatestUrl() {
	USER_AGENT=('User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36')

	URL=$(curl 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' -H 'Origin: https://www.jetbrains.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H "${USER_AGENT[@]}" -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Referer: https://www.jetbrains.com/toolbox/download/' -H 'Connection: keep-alive' -H 'DNT: 1' --compressed | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}'| sed 's/[", ]//g')
	echo $URL
}

if [ "$1" != "$scripts" ]; then
        getLatestUrl
fi


local_dir=/home/${user}/.local/share/JetBrains/Toolbox
if [ -d "$local_dir" ]; then
    chown $user:$NB_GID -R $local_dir
    rm -rf $local_dir
fi

if [ "$1" != "$scripts" ]; then        
    FILE=$(basename ${URL})
fi

DEST=$PWD/$FILE

function proceed() {
	echo ""
	echo -e "\e[94mDownloading Toolbox files \e[39m"
	echo ""
	wget -cO  ${DEST} ${URL} --read-timeout=5 --tries=0
	echo ""
	echo -e "\e[32mDownload complete!\e[39m"
	echo ""
	DIR="$APPDIR"
	echo ""
	echo  -e "\e[94mInstalling to $DIR\e[39m"
	echo ""
	if mkdir -p ${DIR}; then
	    chown $user:$NB_GID -R ${DIR} 
            tar -xzf ${DEST} -C ${DIR} --strip-components=1
	    ln -s ${DIR} $local_dir > /dev/null 2>&1 || echo "$local_dir exists"
	fi
	chmod -R +rwx ${DIR}
}

if [ "$1" != "$scripts" ]; then
	proceed
fi

#echo "NB_USER=$user"

if [[ -L "/home/${user}/.local/bin/jetbrains-toolbox" ]]; then
	    rm -f /home/${user}/.local/bin/jetbrains-toolbox
fi

ln -s ${APPDIR}/jetbrains-toolbox /home/${NB_USER}/.local/bin/jetbrains-toolbox
touch /home/${NB_USER}/.local/bin/toolbox
echo -e "$toolbox_script" | sudo tee /home/${NB_USER}/.local/bin/toolbox > /dev/null
chmod -R +rwx ${APPDIR}/jetbrains-toolbox /home/${NB_USER}/.local/bin/jetbrains-toolbox /home/${NB_USER}/.local/bin/toolbox > /dev/null 2>&1
echo ""

if [ "$1" != "$scripts" ]; then        
        rm ${DEST}
fi

## setting settings
touch ${APPDIR}/.settings.json
echo -e "$toolbox_settings" | tee ${APPDIR}/.settings.json > /dev/null
sed -i "s/NB_USER/$NB_USER/g" $APPDIR/.settings.json

## generating ui launchers
mkdir -p  /home/${NB_USER}/.local/share/applications /home/${NB_USER}/Desktop
touch /home/$NB_USER/Desktop/toolbox.desktop
chmod 755 /home/$NB_USER/Desktop/toolbox.desktop
echo -e "$toolbox_desktop" | sudo tee /home/$NB_USER/Desktop/toolbox.desktop > /dev/null
sudo chown $NB_USER:$NB_GID /home/$NB_USER/Desktop/toolbox.desktop
cp /home/$NB_USER/Desktop/toolbox.desktop /home/${NB_USER}/.local/share/applications/toolbox.desktop


if [ "$1" == "$scripts" ]; then
        echo "Scripts and launchers updated."
fi

echo  -e "\e[32mDone.\e[39m"


