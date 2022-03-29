#!/bin/bash

yum install bgpq3 -y >/dev/null

echo -n "输入需要扫描的AS号（as21859）"

read h

bgpq3 -2 $h | awk -F " " '{print $5}'  >>ip_prefixes



prefixes_list=`shuf -n50 ip_prefixes`

for m in ${prefixes_list}
do
{

#echo "$m"
fping -i 1 -a -g -r 0 $m   >>result.txt

}&

done

wait

rm -rf ip_prefixes


icmpping(){


IP_LIST=`shuf -n200 result.txt`
for b in ${IP_LIST}

do
{
    c=$(ping -c 100 -W 1 -i 0.1 $b|grep rtt |awk '{print $4}' |awk -F'/' '{print $2}')

    echo "$b $c ms"
    echo "$c" >>ping.txt
}&

done

wait

sort -g ping.txt |tr -s '\n' >>ping1.txt

l50=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.5}'|cut -d '.' -f1)
l75=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.75}'|cut -d '.' -f1)
l90=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.90}'|cut -d '.' -f1)
l95=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR*0.95}'|cut -d '.' -f1)

l=$(cat  ping1.txt| awk '{sum+=$1} END {print  NR}')
ll=$(cat  result.txt| awk '{sum+=$1} END {print  NR}')
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
每个IP测试100个ICMP包，求平均值。</font>\n> "
  }
}'



wait
#rm -rf /tmp/ping.txt
rm -rf result.txt
}


icmpping



rm -rf ping.txt
rm -rf ping1.txt
