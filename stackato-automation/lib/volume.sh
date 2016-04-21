
# Delete nonexistent volume from fstab
#
function fstab_cleanup() {
        local fstab_file="${1:-/etc/fstab}"

        local fstab_volume=""
        while read line; do
                fstab_volume="$(echo $line | cut --delimiter=' ' --fields=1)"
                if [ "${fstab_volume:0:1}" == "/" ] && ! volume_exists $fstab_volume; then
                        sed --in-place "\:$fstab_volume:d" $fstab_file
                fi
        done < $fstab_file
}

# Check a volume exists
#
# @return: 1 if missing, else 0
function volume_exists() {
        local volume="${1:?missing input}"

        lsblk $volume &>>/dev/null
}

