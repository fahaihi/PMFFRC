#!/bin/bash
#######################################################################################
#author: SH
#date: 2022/10/15
#describe: A script for P-MFFRC decompressor using spring algorithm
#######################################################################################
de_path=$1
Pr=$2
clean_debug=$3

echo
echo "# 1.parse *pmffrc file"
#folder_temp="pmffrc_de_temp"
dir_path=$(dirname $de_path)
file_name=$(basename $de_path)
folder_temp=de_`basename ${de_path} .pmffrc`
cd $dir_path
if [ -d "${folder_temp}" ]; then
  rm -rf ${folder_temp}
  mkdir ${folder_temp}
else
  mkdir ${folder_temp}
fi
cp $file_name ${folder_temp}
cd ${folder_temp}
pwd_path=${dir_path}/${folder_temp}
tar -xvf $file_name
tar -Jxvf cluster_info.tar
files_num=0

echo
echo "# 2.decompression compressed cluster multi-fastq-files"
spring_decompressor() {
  echo "  call spring algorithm for de-compression!"
  files_list=$(ls)
  for tempFile in ${files_list}; do
    if [[ ${tempFile:$((${#tempFile} - 7))} == ".spring" ]]; then
      echo "  decompression : $tempFile *****************************************************"
      de_file_name=${pwd_path}/${tempFile}
      base_name=`basename ${tempFile} .spring`
      cd ${PMFFRC_PATH}src/Spring/build
      ./spring -d -i ${de_file_name} -o ${pwd_path}/${base_name}.reads
      #mv C_${files_num}.dna.d C_${files_num}.reads
      ((files_num = files_num + 1))
    fi
  done
  echo "  call spring algorithm for de-compression over!"
}
spring_decompressor


echo
echo "# 3.recover cluster reads files"
cd ${pwd_path}
for k in $(seq 0 $((files_num - 1))); do
  c_name="cluster_${k}.clu"
  d_name="C_${k}.reads"
  c_id=$(sed -n 1p ${c_name})
  c_num=$(sed -n 2p ${c_name})
  echo $c_num > ${k}.log
  temp_num=0
  for ((i = 0; i < ${c_num}; i++)); do
    f_name=$(sed -n $((2 + i * 2 + 1))p ${c_name})
    f_number=$(sed -n $((2 + i * 2 + 2))p ${c_name})
    ((temp_num = temp_num + f_number))
    if [[ ${f_name:$((${#f_name} - 6))} == ".fastq" ]]; then f_name_basename=$(basename $f_name .fastq); fi
    if [[ ${f_name:$((${#f_name} - 3))} == ".fq" ]]; then f_name_basename=$(basename $f_name .fq); fi
    f_name_save=${f_name_basename}.read
    echo "$f_name_save" >> ${k}.log
    echo "$f_number" >> ${k}.log
    echo "$temp_num" >> ${k}.log
  done
done

for k in $(seq 0 $((files_num - 1))); do
  echo "  recover cluster_$k *********************************************"
  log_name=$k.log
  log_num=$(sed -n 1p ${log_name})
  for ((i = 0; i < $log_num; i++)); do
    {
      f_name=$(sed -n $((1 + i * 3 + 1))p ${log_name})
      f_num=$(sed -n $((1 + i * 3 + 2))p ${log_name})
      f_sum=$(sed -n $((1 + i * 3 + 3))p ${log_name})
      f_begin=$((f_sum - f_num + 1))
      echo "  " $f_name $f_begin $f_num
      head -${f_sum} C_${k}.reads | tail -${f_num} >$f_name
    } &
  done
  wait
done

if [ ${clean_debug} == "True" ]; then
  echo
  echo "# 4. clear data"
  cd ${dir_path}
  # rm -rf ${folder_temp}
fi

# 查看是否解压缩成功
ls -l --block-size=KB ${dir_path}/${folder_temp}
