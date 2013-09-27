#!/bin/bash
# make sure the user entered something
function checkExists {
    if [ -z "$1" ]; then
        echo "$2 required"
        exit 1
    fi
}

# read in config file
source /etc/installproject/config.cfg

read -e -p "Project Name: " PROJECT_NAME

read -e -p "Repository: " REPOSITORY

checkExists "$REPOSITORY" "Repository"

# determine VCS
case $REPOSITORY in
    *git*) VCS="git" ;;
    *svn*) VCS="svn" ;;
    *) VCS="unknown" ;;
esac

# if we couldn't determine it, ask
if [ "$VCS" = "unknown" ]; then
    read -e -i "git" -p "VCS type: " VCS
fi

# make sure it's git or svn
if [[ "$VCS" != "git" && "$VCS" != "svn" ]]; then
    echo "Invalid VCS"
    exit 1
fi

PROJECT_ROOT="$document_root"/"$PROJECT_NAME"

read -e -p "Path to web root: $PROJECT_ROOT/" WEB_ROOT

WEB_ROOT="$PROJECT_ROOT"/"$WEB_ROOT"

# checkout
if [ ! -d "$PROJECT_ROOT" ]; then
    if [[ "$VCS" = "git" ]];
    then
        git clone "$REPOSITORY" "$PROJECT_ROOT"
    else
        svn checkout "$REPOSITORY" "$PROJECT_ROOT"
    fi
fi

VHOST="$vhost_directory"/"$PROJECT_NAME".conf

# add vhost
if [ ! -f "$VHOST" ]; then
    sudo cp /etc/installproject/vhost.tpl "$VHOST"

    sudo sed -i -e s:@DOCUMENT_ROOT@:"$WEB_ROOT":g "$VHOST"
    sudo sed -i -e s:@SERVER_NAME@:"$PROJECT_NAME":g "$VHOST"
fi

HOST="127.0.0.1 $PROJECT_NAME.dev"

if ! grep -Fxq "$HOST" "$hosts_file"
then
    printf "$HOST" | sudo tee -a "$hosts_file"
fi

sudo apachectl restart
