#!/bin/bash
#######################################################################################
#author: SH
#date: 2022/10/11
#describe: A script for harc_compressor
#######################################################################################
test_files_dir=$1
Pr=$2
U_ram=$3
clean_flag=$4
preserve_quality=$5
test_num=0
folder_name="harc_${Pr}_${U_ram}_pmffrc_output"
save_name=harc_${Pr}_${U_ram}_$(basename ${test_files_dir})

echo
echo "# 1. make output dir"
echo "  savename: ${save_name}.pmffrc"
if [ -d "${test_files_dir}/${folder_name}" ]; then
  rm -rf "${test_files_dir}/${folder_name}"
  mkdir "${test_files_dir}/${folder_name}"
  if [ $? -ne 0 ]; then
    echo "make output dir wrong!"
    exit 0
  fi
else
  mkdir "${test_files_dir}/${folder_name}"
  if [ $? -ne 0 ]; then
    echo "make output dir wrong!"
    exit 0
  fi
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
harc_pre_compression() {
  echo "  call harc algorithm for pre-compression!"
  pwd_p=`pwd`
  #harcPath="/public/home/jd_sunhui/genCompressor/HARC-master"
  harcPath=${PMFFRC_PATH}src/HARC
  cd ${harcPath}
  { /bin/time -v -p ./harc -c ${test_files_dir}/${folder_name}/X1.fastq -p -t 8 >${test_files_dir}/${folder_name}/harc_X1.drop; } 2>${test_files_dir}/${folder_name}/C1.log
  { /bin/time -v -p ./harc -c ${test_files_dir}/${folder_name}/X2.fastq -p -t 8 >${test_files_dir}/${folder_name}/harc_X2.drop; } 2>${test_files_dir}/${folder_name}/C2.log
  echo "  harc pre-compressor over"
  cd ${pwd_p}
  rm ${test_files_dir}/${folder_name}/X1.fastq
  if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
  rm ${test_files_dir}/${folder_name}/X2.fastq
   if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
  rm ${test_files_dir}/${folder_name}/X1.harc
   if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
  rm ${test_files_dir}/${folder_name}/X2.harc
   if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
}
harc_pre_compression
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
Beta=1.35
#{ /bin/time -v -p ./multi_fastq_files_reads_clustering.out $test_files_dir $Pr $U_ram; } 2>${test_files_dir}/${folder_name}/Cluster.log
cd ${PMFFRC_PATH}src
./multi_fastq_files_reads_clustering.out ${test_files_dir} ${Pr} ${U_ram} ${folder_name} ${Beta}
if [ $? -ne 0 ]; then
    echo "clustering wrong!"
    rm -rf ${test_files_dir}/${folder_name}
    exit 0
fi


echo
echo "# 5. merge files"
merge_files() {
  files_list=$(ls ${test_files_dir}/${folder_name})
  touch ${test_files_dir}/${folder_name}/merge.drop
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
harc_compressor() {
  #harcPath="/public/home/jd_sunhui/genCompressor/HARC-master"
  harcPath=${PMFFRC_PATH}src/HARC
  files_list=$(ls ${test_files_dir}/${folder_name})
  for tempFile in ${files_list}; do
    if [[ ${tempFile:$((${#tempFile} - 6))} == ".fastq" ]]; then
      echo "  ***********************${tempFile}*************************"
      pwd_p=`pwd`
      cd ${harcPath}
      if [[ ${preserve_quality} == "True" ]]; then
        ./harc -c ${test_files_dir}/${folder_name}/${tempFile} -q -p -t 8
        if [ $? -ne 0 ]; then
          echo "run harc wrong!"
          exit 0
        fi
      fi
      if [[ ${preserve_quality} == "False" ]]; then
        ./harc -c ${test_files_dir}/${folder_name}/${tempFile} -p -t 8
        if [ $? -ne 0 ]; then
          echo "run harc wrong!"
          exit 0
        fi
      fi
      cd ${pwd_p}
    fi
  done
}
harc_compressor

echo
echo "# 7. pack files to *.pmffrc"
harc_pack() {
  pwd_p=`pwd`
  cd ${test_files_dir}/${folder_name}
  tar -cf cluster_info.tar *.clu
  tar -Jcf cluster_info.tar *.clu
  tar -cf ${save_name}.pmffrc cluster_info.tar *harc
  cp ${save_name}.pmffrc ${test_files_dir}
  cd ${pwd_p}
}
harc_pack


if [ ${clean_flag} == "True" ]; then
  echo
  echo "# 8.clean files"
  echo "  remove temp files"
  rm -rf ${test_files_dir}/${folder_name}
fi

echo
#echo "  files size:"
#ls -l --block-size=KB ${test_files_dir}/${save_name}.pmffrc
echo