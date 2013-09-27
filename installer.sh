#!/bin/bash
# remove trailing slash
function removeSlash {
   echo "${1%/}"
   return 1
}

# make sure user entered something
function checkExists {
    if [ -z "$1" ]; then
        echo "$2 required"
        exit 1
    fi
}

CONFIG_DIRECTORY="/etc/installproject"
CONFIG="$CONFIG_DIRECTORY"/"config.cfg"
INSTALL_REPO_NAME="tmpinstallproject"

read -e -p "Document Root: " DOCUMENT_ROOT

checkExists "$DOCUMENT_ROOT" "Document root"

if [ ! -d "$DOCUMENT_ROOT" ]; then
    echo "Document root does not exist"
    exit 1
fi

read -e -p "Vhost Directory: " VHOST_DIRECTORY

checkExists "$VHOST_DIRECTORY" "Vhost Directory"

if [ ! -d "$VHOST_DIRECTORY" ]; then
    echo "Vhost directory does not exist"
    exit 1
fi

read -e -i "/etc/hosts" -p "Hosts File: " HOSTS

if [ ! -f "$HOSTS" ]; then
    echo "Hosts file does not exist"
    exit 1
fi

read -e -i "/usr/local/bin" -p "Bin Directory: " BIN

if [ ! -d "$BIN" ]; then
    echo "Bin directory does not exist"
    exit 1
fi

DOCUMENT_ROOT=`removeSlash $DOCUMENT_ROOT`
VHOST_DIRECTORY=`removeSlash $VHOST_DIRECTORY`
BIN=`removeSlash $BIN`

# make the install project config directory
if [ ! -d "$CONFIG_DIRECTORY" ]; then
    sudo mkdir "$CONFIG_DIRECTORY"
fi

# remove config file if it already exists
if [ -f "$CONFIG" ]; then
    sudo rm "$CONFIG"
fi

printf "document_root=$DOCUMENT_ROOT\nvhost_directory=$VHOST_DIRECTORY\nhosts_file=$HOSTS" | sudo tee "$CONFIG"

git clone https://github.com/natebrunette/installproject.git "$INSTALL_REPO_NAME"

sudo mv "$INSTALL_REPO_NAME"/installproject.sh "$BIN"/installproject.sh
sudo mv "$INSTALL_REPO_NAME"/vhost.tpl "$CONFIG_DIRECTORY"/vhost.tpl

rm -rf "$INSTALL_REPO_NAME"
