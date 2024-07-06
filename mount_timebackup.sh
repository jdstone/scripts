#!/usr/bin/env bash

#title          :mount_timebackup.sh
#description    :Mount my HFS+ macOS Time Machine backup sparsebundle image.
#author         :J.D. Stone
#date           :20240705
#version        :0.2.0
#usage          :./mount_timebackup.sh
#==============================================================================


## Mount macOS Time Machine backup
SBFS_MOUNT="$(mount | grep -i "sparsebundlefs on /mnt/jds-igg-mbp_disk-image" | cut -d ' ' -f 3)"
if ! [[ "${SBFS_MOUNT}" ]]; then
  /home/jd/bin/sparsebundlefs -o allow_other /mnt/storage/backups/jds-igg-mbp/jds-igg-mbp_TimeMachineBackup.sparsebundle/ /mnt/jds-igg-mbp_disk-image
else
  >&2 echo "[!] ${SBFS_MOUNT} is already mounted."
fi


## Check to see if a loop device for this MBP Time Machine image already exists
LOOP_DEVICE="$(sudo /home/jd/bin/get_igg_tm_di_loop_device.sh)"
## Check /etc/fstab for the MBP Time Machine loop device name
FSTAB_LOOP_DEVICE="$(grep '/mnt/jds-igg-mbp_mount-point' /etc/fstab | cut -d ' ' -f 1)"

if [[ "${SBFS_MOUNT}" ]] && [[ "${LOOP_DEVICE}" == "${FSTAB_LOOP_DEVICE}" ]]; then
  TM_MOUNT=$(mount | grep -i 'tmfs on /mnt/jds-igg-mbp_timemachine')
  if [[ -z "${TM_MOUNT}" ]]; then
    mount /mnt/jds-igg-mbp_mount-point/
  else
    >&2 echo "[!] ${TM_MOUNT} is already mounted."
  fi
else
  sudo /home/jd/bin/create_igg_tm_loop_device.sh
  mount /mnt/jds-igg-mbp_mount-point/
fi

## Final mount of the Time Machine image
if mount | grep -iq "/mnt/jds-igg-mbp_mount-point" && ! mount | grep -iq "tmfs on /mnt/jds-igg-mbp_timemachine"; then
  sudo /home/jd/bin/mount_igg_tm.sh
else
  echo "\"IGG TIME MACHINE BACKUP\" WAS SUCCESSFULLY MOUNTED or IT HAS ALREADY BEEN MOUNTED..."
fi

