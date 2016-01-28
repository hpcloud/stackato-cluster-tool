#!/usr/bin/env bash
: ${CORE_IP:=12.34.56.78}

# Server storing the shared Cloud Controller data
: ${STACKATO_SHARED_DIR_IP:=10.0.0.3}
: ${STACKATO_SHARED_DIR:=/mnt/add-volume/stackato-shared/}

# Default location of the Cloud Controller data
: ${DATA_DIR:=/home/stackato/stackato/data}
: ${DATA_CC_DROPLETS_DIR:=/var/stackato/data/cloud_controller_ng/tmp/staged_droplet_uploads}

# New location of the Cloud controller data (could be a bigger disk)
: ${CONTROLLER_MOUNT_DIR:=/mnt/controller}

# SSHFS mount options
SSHFS_OPTS=( idmap=user
             reconnect
             allow_other
             ServerAliveInterval=15 )

: ${STACKATO_USER:=stackato}
: ${STACKATO_GROUP:=stackato}
: ${FUSE_CONF_PATH:=/etc/fuse.conf}

: ${KATO_BIN:=kato}

# Stop the controller process on the core node
$KATO_BIN stop controller

# Perform the following actions on the core node and each additional controller node
## Create a mount point
sudo mkdir -p $CONTROLLER_MOUNT_DIR
## Give stackato ownership of the mount point
sudo chown -R $STACKATO_USER:$STACKATO_GROUP $CONTROLLER_MOUNT_DIR
## Allow non-root users to specify mount options
sudo sed -i "s/#user_allow_other/user_allow_other/" $FUSE_CONF_PATH
## Mount the shared filesystem on the mount point
SSHFS_OPTS_STRING=""
for sshfs_opt in ${SSHFS_OPTS[@]}; do
  SSHFS_OPTS_STRING="$SSHFS_OPTS_STRING -o $sshfs_opt"
done
sshfs $SSHFS_OPTS_STRING $STACKATO_USER@$STACKATO_SHARED_DIR_IP:$STACKATO_SHARED_DIR $CONTROLLER_MOUNT_DIR
## Move aside the original /home/stackato/stackato/data directory
mv $DATA_DIR $DATA_DIR.old
## Create a symlink from /home/stackato/stackato/data to the mount point
ln -s $CONTROLLER_MOUNT_DIR $DATA_DIR
## Move the original /var/stackato/data/cloud_controller_ng/tmp/staged_droplet_uploads directory
mv $DATA_CC_DROPLETS_DIR $DATA_CC_DROPLETS_DIR.old
## Create a symlink from /var/stackato/data/cloud_controller_ng/tmp/staged_droplet_uploads to the mount point
ln -s $CONTROLLER_MOUNT_DIR $DATA_CC_DROPLETS_DIR

# Copy the controller data and the droplets on the core node into the shared directory
cp -r $DATA_DIR.old/* $DATA_CC_DROPLETS_DIR.old/* $CONTROLLER_MOUNT_DIR
# Start the controller process
$KATO_BIN start controller
# To enable only the controller process, run the following command on the additional controller nodes
$KATO_BIN node attach -e controller $CORE_IP
