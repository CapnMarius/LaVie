#!/bin/bash
clear
echo "Updater script for LaVie-Manager - Aurelia - version 0.2"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
success=true

cd /srv/http/database-editor
rm -rf ./aurelia_backup
mkdir -p ./aurelia_backup/aurelia_project
mkdir -p ./aurelia_backup/crew
mkdir -p ./aurelia_backup/web/cabin

echo "Creating a backup of Aurelia" 
if cp -r ./aurelia ./aurelia_backup_$current_time; then
	echo "Backup succeeded" 
	
	cd /srv/http/database-editor/aurelia
	
	echo "Cleaning project directory" 
	mv ./aurelia_project/environments ../aurelia_backup/aurelia_project/environments
	mv ./Config ../aurelia_backup/Config
	mv ./crew/zones.json ../aurelia_backup/crew/zones.json
	mv ./yamaha_control.php ../aurelia_backup/yamaha_control.php
	mv ./web/cabin/sources.json ../aurelia_backup/web/cabin/sources.json
	
	echo "Downloading updates" 
	if git reset --hard && git pull origin develop; then
		echo "Downloading updates succeeded" 
		rm -rf ./aurelia_project/environments
		cp -r ../aurelia_backup/* ./

		echo "Compiling"
		if ./node_modules/.bin/au build; then
			echo "Compiling succeeded"
		else 
			echo "Compiling failed"
			success=false
		fi
	else 
		echo "Downloading updates failed"
		success=false
	fi
	
	if $success == true; then
		echo "Succeeded, you can now reload the webpage"
	else 
		echo "Failed, reverting backup" 
		if cp -rf ../aurelia_backup_$current_time ./; then
			echo "Backup restore succeeded"
		else 
			echo "Backup restore failed, please try it manually"
		fi
	fi
else
	echo "Backup failed. Aborted"
fi
