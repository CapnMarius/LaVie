#!/bin/bash
clear
echo "Updater script for LaVie-Manager - NodeJS - version 0.2"
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
success=1

cd /srv/http/database-editor
rm -rf ./nodejs_backup
mkdir -p ./nodejs_backup

echo "Creating a backup of NodeJS" 
if cp -r ./nodejs ./nodejs_backup_$current_time; then
	echo "Backup succeeded" 
	
	cd /srv/http/database-editor/nodejs
	
	echo "Cleaning project directory" 
	mv ./environments ../nodejs_backup/environments
	
	echo "Downloading updates" 
	if git reset --hard && git pull origin develop; then
		echo "Downloading updates succeeded" 
		rm -rf ./environments
		cp -r ../nodejs_backup/* ./

		echo "Compiling"
		if ./node_modules/.bin/grunt build; then
			echo "Compiling succeeded"
		else 
			if ./node_modules/.bin/grunt build; then
				echo "Compiling succeeded"
			else 
				echo "Compiling failed"
				success=0
			fi
		fi
	else 
		echo "Downloading updates failed"
		success=0
	fi
	
	if $success == 1; then
		echo "Succeeded, you can now restart the database-editor service as root"
	else 
		echo "Failed, reverting backup" 
		if cp -rf ./nodejs_backup_$current_time ./nodejs; then
			echo "Backup restore succeeded"
		else 
			echo "Backup restore failed, please try it manually"
		fi
	fi
else
	echo "Backup failed. Aborted"
fi
