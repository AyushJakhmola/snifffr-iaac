#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
base_path=/mnt_s3/data/home/576500.cloudwaysapps.com/enjpmgakfz/public_html
minutes=1440
fileType=mp4
bucket_name=media.snifffr.com

#limit total result
#/usr/bin/find $base_path/uploads -name "*.$fileType" -type f -mmin +$minutes -print | head -400 | while read -r i
/usr/bin/find $base_path/arrowchat/uploads -type f -regex '.*\.\(GIF\|JPEG\|JPG\|MP4\|PNG\|bmp\|docx\|ico\|jpeg\|jpg\|mp3\|mp4\|pdf\|png\|pptx\|rar\|txt\|wmv\|zip\|gif\)$' -mmin +$minutes -print | head -500 | while read -r i
do
    echo "----------------------------------------------------"
    echo "Check file => $i"
    remote_path="${i/#$base_path}"
    final_remote_path="${remote_path#/}"
    user_folder="/arrowchat/uploads/"
    user_id_part="${remote_path/#$user_folder}"
    users_id_all_parts=(${user_id_part//\// })
    final_userid=${users_id_all_parts[0]}
    extension="${final_userid##*.}"
    final_fileHash="${final_userid/".$extension"/""}"
    final_fileHash="${final_fileHash/"_t"/""}"

    echo "final ext = $final_fileHash"
    echo "Final user id is => $final_userid"

    echo "final_remote_path ==> $final_remote_path"


    aws s3api head-object --bucket $bucket_name --key $final_remote_path  > /dev/null 2>&1 || not_exist=true
    if [ $not_exist ]; then
        echo "--- $final_remote_path not found on S3, will copy"
        aws s3 cp $i s3://$bucket_name/$final_remote_path --metadata '{"Cache-Control":"max-age=315360000"}'
    else
        echo "*** $final_remote_path found on S3, will check file size remote and local"
        remote_file_size=$(aws s3api head-object --bucket $bucket_name --key $final_remote_path | jq -r .ContentLength)
        local_file_size=$(stat -c%s "$i")
        echo "remote file size is => $remote_file_size  local file size is => $local_file_size"
        if [[ "$remote_file_size" == "$local_file_size" ]]; then
            echo "local and remote are same, safely could delete local file"
            echo "add to Mysql "
            mysql -uenjpmgakfz -p6SPaEpEwDg -h 127.0.0.1 -e "insert into enjpmgakfz.arrowchat_refrence_s3 (fileName,fileHash) values('$final_remote_path',$final_fileHash);"
            echo "delete $i"
            rm -rf $i
        else
            echo "local and remote are not same, should delete remote to reupload again"
#            aws s3 rm
        fi
    fi
done