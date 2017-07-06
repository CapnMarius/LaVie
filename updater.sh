#!/bin/bash
clear
echo "Updater script for LaVie-Manager - version 0.1"

cd /srv/http/database-editor
rm -rf ./backup
mkdir -p ./backup/nodejs
mkdir -p ./backup/aurelia/aurelia_project
mkdir -p ./backup/aurelia/crew
mkdir -p ./backup/aurelia/web/cabin

cd /srv/http/database-editor/nodejs
mv ./environments ../backup/nodejs/environments
git reset --hard && git pull origin develop
rm -rf ./environments
cp -r ../backup/nodejs/* ./

if ./node_modules/.bin/grunt build; then
	echo "NodeJS build successfull, restart database-editor service"
else 
	if ./node_modules/.bin/grunt build; then
		echo "NodeJS build successfull, restart database-editor service"
	else 
		echo "NodeJS build failed. Please try a manual update"
	fi
fi

cd /srv/http/database-editor/aurelia
mv ./aurelia_project/environments ../backup/aurelia/aurelia_project/environments
mv ./Config ../backup/aurelia/Config
mv ./crew/zones.json ../backup/aurelia/crew/zones.json
mv ./yamaha_control.php ../backup/aurelia/yamaha_control.php
mv ./web/cabin/sources.json ../backup/aurelia/web/cabin/sources.json
git reset --hard && git pull origin develop
rm ./aurelia_project/environments
cp -r ../backup/aurelia/* ./

if ./node_modules/.bin/au build; then
        echo "Aurelia build successfull"
else 
        echo "Aurelia build failed. Please try a manual update"
fi

echo "Don't forget to update kodi.service to restart always (
	#sudo nano /lib/systemd/system/kodi.service 
		on-abort -> always
	#sudo systemctl daemon-reload && sudo systemctl restart kodi
)"
