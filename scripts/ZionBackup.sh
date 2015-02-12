#!/bin/bash

TARGET_DIR="/media/usb0"
BACKUP_TYPE_FILE="$TARGET_DIR/.backup-type"
BACKUPTYPE=$(<$BACKUP_TYPE_FILE)
LOGFILE="$BACKUPTYPE-backup-$(date +"%Y%m%d-%H%M").txt"
LOGPATH="/var/log/backupscript/$LOGFILE"
START_TIME=$(date +%s)
MESSAGE_CONTENT=""
CLEANUP_DELETED=0
REQUIRES_DELETIONS=0

# Process args
while test $# -gt 0; do
  case "$1" in
    --cleanup) CLEANUP_DELETED=1;;
  esac
  shift
done


function backup_dir() {
  SOURCE_DIR="$1"
  SOURCE_NAME=$(basename "$SOURCE_DIR")
  if [ -f $LOGPATH ] && [ -s $LOGPATH ]; then
    echo -e "\n\n" &>> $LOGPATH
  fi
  echo "Backing up $SOURCE_DIR" &>> $LOGPATH
  rsync -vrltD --stats "$SOURCE_DIR" "$TARGET_DIR" &>> $LOGPATH
  STATS="$(tail -n 14 $LOGPATH)"
  MESSAGE_CONTENT+="\n\n$SOURCE_NAME\n$STATS"

  # Check if there have been any deleted files
  TO_DELETE=$(rsync -irltD --delete --dry-run "$SOURCE_DIR" "$TARGET_DIR" | sed -e 's/*deleting  /-/g')
  if [ ! -z "$TO_DELETE" ]; then
    if [ $CLEANUP_DELETED -eq 1 ]; then
      echo -e "\n\nCleaning up deleted files" &>> $LOGPATH
      rsync -vrltD --delete "$SOURCE_DIR" "$TARGET_DIR" &>> $LOGPATH
      MESSAGE_CONTENT+="\n\nDeleted $(echo "$TO_DELETE" | wc -l) file(s):\n$TO_DELETE"
    else
      CONTENT="\n\nFiles to be deleted in $SOURCE_NAME:\n$TO_DELETE"
      CONTENT+="\nRe-run script with --cleanup parameter to really delete\n"
      MESSAGE_CONTENT+="$CONTENT"
      echo -e "$CONTENT" &>> $LOGPATH
      REQUIRES_DELETIONS=1
    fi
  fi
}


function sendEmailSummary() {
  SUBJECT="Backup script complete"
  if [ $REQUIRES_DELETIONS -eq 1 ]; then
    SUBJECT+=" with files for deletion"
  fi
  RECIPIENT="sfrost007@gmail.com"

  END_TIME=$(date +%s)
  DURATION=$(($END_TIME-$START_TIME))
  MESSAGE_CONTENT+="\n\nBackup complete! Took $DURATION seconds."

  (echo -e $MESSAGE_CONTENT; uuencode "$LOGPATH" "$LOGFILE") | mailx -s "$SUBJECT" "$RECIPIENT"
}



echo "Giving filesystem chance to mount.."
sleep 10
if [[ ! -f $BACKUP_TYPE_FILE ]]; then
  echo "No backup-type identifier found, exiting.."
  exit 0
fi

if [[ "$BACKUPTYPE" = "Movies" ]]; then
  echo "Running Movies backup"
  backup_dir "/storage/Media/Movies"
  backup_dir "/storage/Media/Snowboard Movies"
  backup_dir "/storage/Media/Skate Movies"
  backup_dir "/storage/Media/Documentaries"
  backup_dir "/storage/Documents/My Videos"

elif [[ "$BACKUPTYPE" = "TV" ]]; then
  echo "Running TV Shows backup"
  backup_dir "/storage/Media/TV Programs"

else
  echo "Unknown backup type!"
  exit 1
fi

sendEmailSummary

