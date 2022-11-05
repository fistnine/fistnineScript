#!/bin/bash
#将根据文件夹分类的文件处理为m3u的list
#文件夹名称不能重复

_url='https://www.ninestarworks.top:9999/music/' #添加webdav的前缀地址
_PATH='/mnt/disk0/Programs/Music_backup/' #需要处理的根目录
_out='./out/' #输出文件夹
_suffix='.m3u' #list后缀
num=0 #用于计数处理了多少文件

mkdir $_out
find "$_PATH" -type d -exec echo {} \; | sed "s|^[^=]*/||g" | xargs -i touch $_out{}$_suffix

for i in `ls $_out | tr " " "\?"` #解决for识别ls空格为分隔符问题
do
	i=`tr "\?" " " <<<$i`
	_var=$i
	_var=${_var%$_suffix*} #清理后缀
	_dir=`find "$_PATH" -type d -name $_var`
	for k in `ls "$_dir" | tr " " "\?"`
	do
		k=`tr "\?" " " <<<$k`
		find "$_dir" -type f -name "$k" | sed "s|^[^=]*/||g" | sed "s|^|$_url|g" >> $_out$_var$_suffix
		#find "$_dir" -type f -name "$k" | sed "s|$_PATH||g" | sed "s|^|$_url|g" >> $_out$_var$_suffix
	done
	num=$(($num + 1))
	echo "正在处理第$num个文件"
done
