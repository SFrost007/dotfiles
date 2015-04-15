#!/bin/bash

# Process args
BACKUP_TYPE=$1; shift
if [ -z $BACKUP_TYPE ] || [ ! -d "/var/run/usbmount/$BACKUP_TYPE" ]; then
  echo "Usage: $(basename $0) drive_label [--cleanup]"
  echo "   Drive label must exist as a symlink in /var/run/usbmount."
  echo "   --cleanup will remove files which have been deleted on the source."
  echo " "
  exit 1
fi

CLEANUP_DELETED=0
UNMOUNT_WHEN_DONE=0
while test $# -gt 0; do
  case "$1" in
    --cleanup) CLEANUP_DELETED=1;;
    --unmount) UNMOUNT_WHEN_DONE=1;;
  esac
  shift
done

TARGET_DIR="/var/run/usbmount/$BACKUP_TYPE"
LOGFILE="$BACKUP_TYPE-backup-$(date +"%Y%m%d-%H%M").txt"
LOGPATH="/var/log/backupscript/$LOGFILE"
START_TIME=$(date +%s)
MESSAGE_CONTENT=""
REQUIRES_DELETIONS=0


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

if [[ "$BACKUP_TYPE" = "MoviesEtc" ]]; then
  echo "Running Movies backup" | wall
  backup_dir "/storage/Media/Movies"
  backup_dir "/storage/Media/Snowboard Movies"
  backup_dir "/storage/Media/Skate Movies"
  backup_dir "/storage/Media/Documentaries"
  backup_dir "/storage/Media/Podcasts"
  backup_dir "/storage/Media/Stand-Up"
  backup_dir "/storage/Documents/My Videos"

elif [[ "$BACKUP_TYPE" = "TV" ]]; then
  echo "Running TV Shows backup" | wall
  backup_dir "/storage/Media/TV Programs"

else
  echo "Unknown backup type!"
  exit 1
fi

sendEmailSummary

if [ $UNMOUNT_WHEN_DONE -eq 1 ]; then
  umount $TARGET_DIR
fi

