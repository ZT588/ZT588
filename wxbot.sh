#!/bin/bash
time=$(date "+%Y%m%d")

Webhook=https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=e2c3459e-6120-45b9-a625-b362xxxx
file_dir=/root  #文件所在目录


msg () {
key=$(echo $Webhook | awk -F = '{print $2}')
if test -s $file_dir; then
    file_id=`curl -s -F media=@$file_juedui "https://qyapi.weixin.qq.com/cgi-bin/webhook/upload_media?key=$key&type=file" |awk 'END{print}'|awk  -F '"'  '{print $14}'`
else
    echo 未检测到文件，脚本退出
        exit 1
fi

curl ${Webhook} \
   -H 'Content-Type: application/json' \
   -d '
   {
        "msgtype": "file",
        "file": {
           "media_id": "'$file_id'"
            
        }
   }'

}


for file in `ls $file_dir`; do
    file_juedui="$file_dir/$file"
    msg
    mkdir -p /home/back_file
    mv $file_juedui /home/back_file
done
