#!/bin/bash

echo "Giving filesystem chance to mount.."
sleep 10
if [[ ! -f /media/usb0/.backup-type ]]; then
  echo "No backup-type identifier found, exiting.."
  exit 0
fi


BACKUPTYPE=$(</media/usb0/.backup-type)
LOGFILE="$BACKUPTYPE-backup-$(date +"%Y%m%d-%H%M").log"
LOGPATH="/var/log/backupscript/$LOGFILE"
RSYNC_CMD="rsync -vrltD --delete --stats"
TARGET_DIR="/media/usb0"

if [[ "$BACKUPTYPE" = "Movies" ]]; then
  echo "Running Movies backup"
  $RSYNC_CMD /storage/Media/Movies $TARGET_DIR &>> $LOGPATH
  # TODO: Add Snowboard Movies, Documentaries, My Movies etc.

elif [[ "$BACKUPTYPE" = "TV" ]]; then
  echo "Running TV Shows backup"
  $RSYNC_CMD /storage/Media/TV\ Programs $TARGET_DIR &>> $LOGPATH

else
  echo "Unknown backup type!"
fi


# TODO: Add some message content. Maybe the tail of each rsync output?
uuencode $LOGPATH $LOGFILE | mailx -s "Backup script complete" -r "zion@orangeninja.com" "sfrost007@gmail.com"

# TODO: unmount the drive?

