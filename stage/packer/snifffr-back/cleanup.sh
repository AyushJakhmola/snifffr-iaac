#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

base_path=/mnt_s3/data/home/576500.cloudwaysapps.com/enjpmgakfz/public_html/wp-content
minutes=1440
fileType=mp4
bucket_name=media.snifffr.com

#limit total result
#/usr/bin/find $base_path/uploads -name "*.$fileType" -type f -mmin +$minutes -print | head -400 | while read -r i
/usr/bin/find $base_path/uploads -type f -regex '.*\.\(avi\|mov\|mp4\|jpg\|jpeg\|gif\|png\|webp\)$' -mmin +$minutes -print |  /usr/bin/grep -v '/avatars' | /usr/bin/grep -v '/gravity_forms' | /usr/bin/grep -v '/buddypress' | /usr/bin/head -500 | while read -r i
do
    echo "----------------------------------------------------"
    echo "Check file => $i"
    remote_path="${i/#$base_path}"
    final_remote_path="${remote_path#/}"

    /usr/bin/aws s3api head-object --bucket $bucket_name --key $final_remote_path  > /dev/null 2>&1 || not_exist=true
    if [ $not_exist ]; then
        echo "--- $final_remote_path not found on S3, will copy"
        /usr/bin/aws s3 cp $i s3://$bucket_name/$final_remote_path --metadata '{"Cache-Control":"max-age=315360000"}'
    else
        echo "*** $final_remote_path found on S3, will check file size remote and local"
        remote_file_size=$(aws s3api head-object --bucket $bucket_name --key $final_remote_path | jq -r .ContentLength)
        local_file_size=$(stat -c%s "$i")
        echo "remote file size is => $remote_file_size  local file size is => $local_file_size"
        if [[ "$remote_file_size" == "$local_file_size" ]]; then
            echo "local and remote are same, safely could delete local file"
            echo "delete $i"
            /usr/bin/rm -rf $i
        else
            echo "local and remote are not same, should delete remote to reupload again"
#            aws s3 rm
        fi
    fi
done