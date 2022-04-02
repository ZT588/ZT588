#!/bin/bash



echo -n "输入需要扫描的AS号（as21859）"

read h

filepath=$(pwd)

ipfile="$filepath/alive_$h.txt"

asping(){

#bgpq3 -2 $h | awk -F " " '{print $5}'  >>ip_prefixes

curl  http://v.zt588.pro/ASN/iplist.csv | grep $h | awk -F ',' '{print $1}' >> ip_prefixes


prefixes_list=`shuf -n50 ip_prefixes`

for m in ${prefixes_list}
do
{

#echo "$m"
fping -i 1 -a -g -r 0 $m   >>AS_$h.txt

}&

done

wait

rm -rf ip_prefixes

shuf -n200 AS_$h.txt|awk -F '[' '{print $1}' >>alive_$h.txt

}

zenftp(){

#!/bin/sh

ftp -v -n v.zt588.pro<<EOF

user zenlayer iAcdEt2Gzj6tyfrx
binary

cd IPinfor

put $file_name
bye

EOF

echo "commit to ftp successfully"
}






icmpping(){

file_name=$(date -d "today" +"%Y%m%d_%H%M%S")-$h.txt

#shuf -n200 AS_$h.txt >>alive_$h.txt


#IP_LIST=`shuf -n200 AS_$h.txt`

IP_LIST=`cat alive_$h.txt`


for b in ${IP_LIST}

do
{
    c=$(ping -c 100 -W 1 -i 0.1 $b|grep rtt |awk '{print $4}' |awk -F'/' '{print $2}')

    echo "$b $c ms">>$file_name
    echo "$c" >>ping.txt

}&

done

wait

l50=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.5}'|cut -d '.' -f1)
l75=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.75}'|cut -d '.' -f1)
l90=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.90}'|cut -d '.' -f1)
l95=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.95}'|cut -d '.' -f1)

l=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR}')
ll=$(cat  AS_$h.txt| awk '{sum+=$1} END {print  NR}')
k=$(cat ping1.txt| awk '{sum+=$1} END {print "平均延迟 =", sum/NR}'|awk -F '=' '{print $2}')

p50=$(cat ping1.txt|awk  NR==$l50)
p75=$(cat ping1.txt|awk  NR==$l75)
p90=$(cat ping1.txt|awk  NR==$l90)
p95=$(cat ping1.txt|awk  NR==$l95)

avg=$(echo $k)

echo "==========$h ICMP result=================================="


echo "p50: $p50 ms  p75: $p75 ms p90: $p90 ms p95: $p95 ms "



echo "$k ms"


echo "测试IP数量：$l  测试IP段：$ll"


echo "============================================================="



curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=3cd9e34d-9d84-49a7-a144-69a33750b3dd' \
   -H 'Content-Type: application/json' \
   -d '
   {
  "msgtype": "markdown",
  "markdown": {
    "content": "<font color=\"info\">'$h'</font> ICMP延迟测试结果，平均延迟: <font color=\"info\">'$avg'ms</font>\n> P50: <font color=\"warning\">'$p50'ms</font>\n> P75: <font color=\"warning\">'$p75'ms</font>\n> P90: <font color=\"warning\">'$p90'ms</font>\n> P95: <font color=\"warning\">'$p95'ms</font>\n> \n <font color=\"comment\">测试方法：随机抽取50个IP段，总计'$ll'个存活IP，随机抽取200个IP，
每个IP测试100个ICMP包，求平均值。</font>\n> [IP 详情](http://g.zt588.pro/IPinfor/'$file_name')     [AS详情](https://bgp.he.net/'$h')     [PeeringDB](https://www.peeringdb.com/search?q='$h')"
  }
}'




wait
#rm -rf /tmp/ping.txt
#rm -rf AS_$h.txt
}


if [ ! -f "$ipfile" ]; then

 echo "文件夹不存在 $ipfile"

 asping
 icmpping
 zenftp
else

 echo "文件夹存在 $ipfile"
 icmpping
 zenftp
fi

#icmpping
#zenftp



rm -rf ping1.txt
rm -rf $file_name
