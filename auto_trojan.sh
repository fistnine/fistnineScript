#!/bin/bash
_file=~/docker_conf/trojan-go/config.json #输出文件
_cache=$_file.cache #缓存文件
#_url="https://mie-sub.pz.pe/subscribe/Z83MBXDVJW4NB2W3?node=trojan&regex=.%2B%E6%97%A5.%2B" #只有订阅日本节点
_url="https://mie-sub.pz.pe/subscribe/Z83MBXDVJW4NB2W3?node=trojan" #全部节点

#传入第一个参数 用来判断切换到第几个节点
var1=${1} #节点数字
var2=${2} #是否联网更新节点 默认0为不更新 1为更新

function write(){ #写入文件
	str=${1}
	#获取密码
	_password=${str%%@*}
	_password=${_password#*trojan://}
	str=${str#*@} #删除字符中的_password
	_remote_addr=${str%%:*}
	str=${str#*:} #删除字符中的_remote_addr
	_remote_port=${str%%\?*}
	str=${str#*\?} #删除字符中的_remote_port
	_sni=${str#*sni=}
	_sni=${_sni%%#*}
	str=${str#*#} #删除字符中的_sni
	#写入到配置文件
	echo "{" > $_file
	echo "    \"run_type\": \"client\"," >> $_file
	echo "    \"local_addr\": \"0.0.0.0\"," >> $_file
	echo "    \"local_port\": 1080," >> $_file
	echo "    \"remote_addr\": \"$_remote_addr\"," >> $_file
	echo "    \"remote_port\": $_remote_port," >> $_file
	echo "    \"password\": [" >> $_file
	echo "        \"$_password\"" >> $_file
	echo "    ]," >> $_file
	echo "    \"log_level\": 1," >> $_file
	echo "    \"ssl\": {" >> $_file
	echo "        \"sni\": \"$_sni\"," >> $_file
	echo "        \"alpn\": [" >> $_file
	echo "            \"h2\"," >> $_file
	echo "            \"http/1.1\"" >> $_file
	echo "        ]" >> $_file
	echo "    }" >> $_file
	echo "}" >> $_file
	echo "#已切换#"
	printf $(echo -n $str | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')"\n"
	sudo docker restart trojan-go #重启trojan-go
}

function update(){ #获取订阅 解码 写入缓存
	#if [ -f $_file ] ; then
		#如果存在文件 执行备份
		#cp $_file $(date "+%Y%m%d%H%M%S")$_file.backup
	#fi #备份功能未开启
	echo "正在更新缓存文件... \n $_cache"
	unset http_proxy #取消使用代理
	unset https_proxy
	curl $_url | base64 -d > $_cache
	sed -i '/^\s*$/d' $_cache #删除空行
	#sed -i "s|\strojan|\ntrojan|g" $_cache #根据trojan换行
}

if [ -f $_cache ] ; then #判断是否存在缓存文件
	if [[ -n $var2 ]] ; then #是否有第2个参数 强制更新
		echo "因参数强制更新..."
		update
	else
		echo "存在缓存文件 使用缓存文件获取节点..."
	fi
else
	echo "未发现缓存文件 强制更新缓存文件..."
	update
fi

#获得行数
line=`wc -l $_cache`
line=${line%% *}

if [[ -n $var1 ]] ; then #是否有第1个参数
	#判断传入的数字是否超出整个节点范围
	if (($var1 <= $line)) ; then
		str=`sed -n "$var1"p $_cache` #获取当前行的数据
		write $str #写入节点
	else
		echo "Error:Input number > $line"
		exit 1
	fi
else
	#没有传入参数则不切换 列出所有节点
	echo "#缓存中的所有节点#"
	#获取缓存中的所有的节点名称 并且在前面标注编号
 	for i in `cat $_cache`
 	do
 		line1=$((line1+1))
 		i=${i##*#}
 		printf "$line1--"
 		printf $(echo -n $i | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')"\n"
 	done
	echo "#未修改节点#"
fi
echo "一共有节点 $line"

str=`grep remote_addr $_file`
str=${str##*: }
echo "当前节点为$str"
