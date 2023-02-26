#!/bin/bash
#遍历文件夹及其子文件夹内所有文件，并查看各个文件大小
dir="./" #要遍历的目录

#子函数getdir
function getdir()
{
    for element in `ls $1`
    do
        file=$1"/"$element
        if [ -d $file ]
        then
            getdir $file
        else
            echo $file 1>> /root/dir.out #将结果保存到/root/dir.out
        fi
    done
}

getdir $dir #引用子函数
for line in `cat /root/dir.out`  #读取文件dir.out的每行
do
    filesize=`ls -l $line | awk '{ print $5 }'`  #读取文件大小
    echo $filesize
done


function getdir(){
    echo $1
    for file in $1/*
    do
    if test -f $file
    then
        echo $file
        arr=(${arr[*]} $file)
    else
        getdir $file
    fi
    done
}
getdir /wls
echo ${arr[@]}
