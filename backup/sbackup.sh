#!/bin/bash
#
# Script for do automatic backups files and dbs (mysql, pgsql)
# to Selectel Cloud Storage (http://selectel.ru/services/cloud-storage/)
#
# version: 1.1
#
# Authors:
# - Konstantin Kapustin <sirkonst@gmail.com>
#

# ------- Settings -------
# Selectel Storage settings
SS_USER="25714_atonex"  # Storage user
SS_PWD="3MRLWaUbn9"  # Storage password
SS_CONTAINER="atonex"  # Storage container where we put backup files

# Backup settings
BACKUP_NAME="tendercrm"  # Name for backup, default the last folder name in target
BACKUP_DIR="/var/backups/$BACKUP_NAME"  # Where our backup will be placed

# SQL backup settings
DB_TYPE="mysql"
DB_NAME="tendercrm"  # Database name, set __ALL__ for backup all dbs or empty for disable backup
#DB_NAME=""  # Database name, set __ALL__ for backup all dbs or empty for disable backup
DB_USER="root"
DB_PWD="vindex"
DB_CONTAINER_NAME='tendercrm-db'

EMAIL="kozlovsv78@gmail.com"  # Email for send log, set empty if don't want seng log
EMAIL_ONLY_ON_ERROR="no"  # Send a email only if there was something strange (yes:no) 

DELETE_LOG="yes"  # remove log when finished? (yes:no)
UPLOAD_TO_STORAGE="yes"  # upload to storage (yes:no)
DELETE_BACKUPS_AFTER_UPLOAD="yes"  # remove backups files after successful upload to Storage (yes:no)
# How long store backup in the Storage (in days)? If you set 30, uploaded file will be auto removed after 30 days.
STORAGE_EXPIRE="5"

# ------- Utils -------
#SUPLOAD=`which supload`
# or set path manual
SUPLOAD="/usr/local/bin/supload.sh"
TAR=`which tar`
SENDMAIL=msmtp

# ------- Checking -------
if [ -z "$SS_USER" ] || [ -z "$SS_PWD" ] || [ -z "$SS_CONTAINER" ]; then
	echo "[!] Please set Selectel Storage settings first!"
	exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
	mkdir "$BACKUP_DIR"
	if [ $? -ne 0 ]; then
		echo "[!] Can not create backup dir $BACKUP_DIR!"
		exit 1
	fi
fi

if [ -n "$EMAIL" ] && [ -z "$SENDMAIL" ]; then
	echo "[!] sendmail is not installed!"
	exit 1
fi

if [ -n "$STORAGE_EXPIRE" ]; then
	if [ "$STORAGE_EXPIRE" -eq "$STORAGE_EXPIRE" ] 2>/dev/null; then
		:
	else
		echo "[!] STORAGE_EXPIRE must be a positive integer!"
		exit 1
	fi
fi

# ------- Preparation -------
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm)
BACKUP_FILENAME="${BACKUP_NAME}_$TIMESTAMP.tar.gz"
LOG_FILE="$BACKUP_DIR/log_$BACKUP_NAME-$TIMESTAMP.log"

if [ x"$DB_NAME" = "x__ALL__" ]; then
	DB_BACKUP_FILENAME="${DB_TYPE}_${BACKUP_NAME}_ALL_$TIMESTAMP.sql"
	DB_NAME=""
	DB_TABLES=""
else
	if [ -z "$DB_NAME" ]; then
		DB_BACKUP_FILENAME=""
	else
		DB_BACKUP_FILENAME="${DB_TYPE}_${BACKUP_NAME}_${DB_NAME}_$TIMESTAMP.sql"
	fi
fi

# detect interective mode
if [[ -t 1 ]]; then
	IM="1"                
else
	IM="0"                    
fi

set -o pipefail
_log() {
	while read line; do
		if [ x"$IM" == x"1" ]; then
			echo "$line" | tee -a "$LOG_FILE"
		else
			echo "$line" >> "$LOG_FILE"
		fi
	done
}

_error="0"

exec 2>>"$LOG_FILE"
echo "$(date +%H:%M:%S) Begin backup $BACKUP_NAME" | _log

# ------- Backup databases -------
if [ -n "$DB_BACKUP_FILENAME" ]; then
	# Create database dump
	echo "$(date +%H:%M:%S) Creating DB dump for ${DB_NAME:-ALL dbs}" | _log
	if docker exec $DB_CONTAINER_NAME /usr/bin/mysqldump --no-create-info=FALSE --order-by-primary=FALSE --force=FALSE --no-data=FALSE --flush-privileges=FALSE --compress=TRUE --replace=FALSE --insert-ignore=FALSE --extended-insert=TRUE --quote-names=TRUE --hex-blob=FALSE --complete-insert=FALSE --add-locks=TRUE --disable-keys=TRUE --delayed-insert=FALSE --create-options=TRUE --delete-master-logs=FALSE --comments=TRUE --default-character-set=utf8 --max_allowed_packet=1G --flush-logs=FALSE --dump-date=TRUE --lock-tables=TRUE --allow-keywords=FALSE --events=FALSE --routines -u "$DB_USER" -p"$DB_PWD" "${DB_NAME:---all-databases}" > "$BACKUP_DIR/$DB_BACKUP_FILENAME"
	then
	    echo "$(date +%H:%M:%S) Database backup OK. Put to $BACKUP_DIR/$DB_BACKUP_FILENAME ($db_size)" | _log
	else
	    _error="1"
	    echo "$(date +%H:%M:%S) Database backup ERROR" | _log
	    exit
	fi
fi


# Создаем архив
if $TAR -czpf "$BACKUP_DIR/$BACKUP_FILENAME" ${tar_exc} $DIR_SOURCE $BACKUP_DIR/*.sql 
then
	echo "$(date +%H:%M:%S) Archiving files OK" | _log
	files_size=$(du -h "$BACKUP_DIR/$BACKUP_FILENAME" | cut -f1)
	echo "$(date +%H:%M:%S) Files backup put to $BACKUP_DIR/$BACKUP_FILENAME ($files_size)" | _log 
	# Удаляем временные файлы
else
	echo "$(date +%H:%M:%S) Archiving files ERROR" | _log
	_error="1"
fi

rm -f $BACKUP_DIR/{*.sql,*.bak}

# ------- Upload backups -------
if [ x"$UPLOAD_TO_STORAGE" = x"yes" ] && [ x"$_error" = x"0" ]; then
    echo "$(date +%H:%M:%S) Uploading backup files to Selectel Storage..." | _log

    _u_opts=""
    if [ -n "$STORAGE_EXPIRE" ]; then
        _u_opts="-d ${STORAGE_EXPIRE}d"
    fi
    $SUPLOAD -u "$SS_USER" -k "$SS_PWD" $_u_opts "$SS_CONTAINER" "$BACKUP_DIR/$BACKUP_FILENAME" | _log
    if [ $? -ne 0 ]; then
        _error="1"
    else
        if [ x"$DELETE_BACKUPS_AFTER_UPLOAD" = x"yes" ]; then
            rm -f "$BACKUP_DIR/$BACKUP_FILENAME"
            echo "$(date +%H:%M:%S) File $_file was removed" | _log
        fi
    fi
fi

# ------- Clearing and notification -------
if [ x"$_error" = x"0" ]; then
	echo "$(date +%H:%M:%S) Backup complete, have a nice day!" | _log
	_title="[Backup log] $BACKUP_NAME ($TIMESTAMP)"
else
	echo "$(date +%H:%M:%S) Backup complete with errors, see log $LOG_FILE." | _log
	_title="[Backup log - !ERRORS!] $BACKUP_NAME ($TIMESTAMP)"
fi

if [ -n "$SENDMAIL" ] && [ -n "$EMAIL" ]; then
	if [ x"$_error" = x"0" ] && [ x"$EMAIL_ONLY_ON_ERROR" = x"yes" ]; then
		:
	else
		cat - "$LOG_FILE" << EOF | $SENDMAIL $EMAIL
Subject:$_title

EOF
	fi
fi

if [ x"$DELETE_LOG" = x"yes" ] && [ x"$_error" = x"0" ]; then
	rm -f "$LOG_FILE"  # Delete log file
fi
