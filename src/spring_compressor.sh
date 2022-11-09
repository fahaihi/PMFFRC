#!/bin/bash
#######################################################################################
#author: SH
#date: 2022/10/15
#describe: A script for spring_compressor
#######################################################################################
test_files_dir=$1
Pr=$2
U_ram=$3
clean_flag=$4
preserve_quality=$5
test_num=0
folder_name=spring_${Pr}_${U_ram}_pmffrc_output
save_name=spring_${Pr}_${U_ram}_$(basename ${test_files_dir})

echo
echo "# 1. make output dir"
echo "  savename: ${save_name}.pmffrc"
echo "  folder_name: ${folder_name}"
if [ -d "${test_files_dir}/${folder_name}" ]; then
  rm -rf "${test_files_dir}/${folder_name}"
  mkdir "${test_files_dir}/${folder_name}"
else
  mkdir "${test_files_dir}/${folder_name}"
fi

echo
echo "# 2. extract fastq-files from test files path"
files_list=$(ls ${test_files_dir})
touch ${test_files_dir}/${folder_name}/X1.fastq
touch ${test_files_dir}/${folder_name}/X2.fastq
for tempFile in ${files_list}; do
  if [[ ${tempFile:$((${#tempFile} - 3))} == ".fq" ]] || [[ ${tempFile:$((${#tempFile} - 6))} == ".fastq" ]]; then
    head -400 ${test_files_dir}/${tempFile} >> ${test_files_dir}/${folder_name}/X1.fastq
    head -400400 ${test_files_dir}/${tempFile} >> ${test_files_dir}/${folder_name}/X2.fastq
    ((test_num = test_num + 100000))
  fi
done
echo ${test_num} > ${test_files_dir}/${folder_name}/X.log

echo
echo "# 3. call other algorithm to compress X.fastq"
spring_pre_compression() {
  echo "  call spring algorithm for pre-compression!"
  # spring 已经配置好变量，推荐配置变量后使用
  { /bin/time -v -p spring -c -i ${test_files_dir}/${folder_name}/X1.fastq -o ${test_files_dir}/${folder_name}/X1.spring --no-quality --no-ids -t 8 >${test_files_dir}/${folder_name}/spring_X1.drop; } 2>${test_files_dir}/${folder_name}/C1.log
  { /bin/time -v -p spring -c -i ${test_files_dir}/${folder_name}/X2.fastq -o ${test_files_dir}/${folder_name}/X2.spring --no-quality --no-ids -t 8 >${test_files_dir}/${folder_name}/spring_X2.drop; } 2>${test_files_dir}/${folder_name}/C2.log
  echo "  spring pre-compressor over"
  rm ${test_files_dir}/${folder_name}/X1.fastq
  rm ${test_files_dir}/${folder_name}/X2.fastq
  rm ${test_files_dir}/${folder_name}/X1.spring
  rm ${test_files_dir}/${folder_name}/X2.spring
}
spring_pre_compression
a=$(sed -n 10p ${test_files_dir}/${folder_name}/C1.log | tr -cd "[0-9]")
b=$(sed -n 10p ${test_files_dir}/${folder_name}/C2.log | tr -cd "[0-9]")
echo "  X1-Y_cpm: $a KB"
echo "  X2-Y_cpm: $b KB"
echo "  Y_diff: $((b - a)) KB"
echo "  test_num: $test_num Reads"
echo $((b - a)) >> ${test_files_dir}/${folder_name}/X.log
echo $((a)) >> ${test_files_dir}/${folder_name}/X.log
echo >> ${test_files_dir}/${folder_name}/X.log

echo
echo "# 4. clustering"
Beta=0.20
#{ /bin/time -v -p ./multi_fastq_files_reads_clustering.out $test_files_dir $Pr $U_ram; } 2>${test_files_dir}/${folder_name}/Cluster.log
./multi_fastq_files_reads_clustering.out ${test_files_dir} ${Pr} ${U_ram} ${folder_name} ${Beta}
if [ $? -ne 0 ]; then
    echo "clustering wrong!"
    rm -rf ${test_files_dir}/${folder_name}
    exit 0
fi

exit 0

echo
echo "# 5. merge files"
merge_files() {
  files_list=$(ls ${test_files_dir}/${folder_name})
  touch "${test_files_dir}/${folder_name}/merge.drop"
  for tempFile in ${files_list}; do
    {
      if [[ ${tempFile:$((${#tempFile} - 4))} == ".clu" ]]; then
        k=$(head -1 ${test_files_dir}/${folder_name}/$tempFile)
        { cat $(cat ${test_files_dir}/${folder_name}/$tempFile) > ${test_files_dir}/${folder_name}/"C_${k}.fastq"; } 2>>${test_files_dir}/${folder_name}/merge.drop
      fi
    }&
  done
  wait
}
merge_files

echo
echo "# 6. compression cluster files"
spring_compressor() {
  echo "***********************"
  files_list=$(ls ${test_files_dir}/${folder_name})
  for tempFile in ${files_list}; do
    echo $tempFile
    if [[ ${tempFile:$((${#tempFile} - 6))} == ".fastq" ]]; then
      echo $tempFile
      base_name=`basename ${tempFile} .fastq`
      echo "  ***********************${tempFile}*************************"
      if [[ ${preserve_quality} == "True" ]]; then
        spring -c -i ${test_files_dir}/${folder_name}/${tempFile} -o ${test_files_dir}/${folder_name}/${base_name}.spring -t 8
      fi
      if [[ ${preserve_quality} == "False" ]]; then
        spring -c -i ${test_files_dir}/${folder_name}/${tempFile} -o ${test_files_dir}/${folder_name}/${base_name}.spring --no-quality --no-ids -t 8
      fi
    fi
  done
}
spring_compressor

echo
echo "# 7. pack files to *.pmffrc"
spring_pack() {
  pwd_p=`pwd`
  cd ${test_files_dir}/${folder_name}
  tar -cf cluster_info.tar *.clu
  tar -Jcf cluster_info.tar *.clu
  tar -cf ${save_name}.pmffrc cluster_info.tar *spring
  cp ${save_name}.pmffrc ${test_files_dir}
  cd ${pwd_p}
}
spring_pack


if [ ${clean_flag} == "True" ]; then
  echo
  echo "# 8.clean files"
  echo "  remove temp files"
  rm -rf ${test_files_dir}/${folder_name}
fi

echo
echo "  files size:"
ls -l --block-size=KB ${test_files_dir}/${save_name}.pmffrc
echo