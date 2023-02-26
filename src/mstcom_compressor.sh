#!/bin/bash
#######################################################################################
#author: SH
#date: 2022/10/15
#describe: A script for mstcom_compressor
#######################################################################################
test_files_dir=$1
Pr=$2
U_ram=$3
clean_flag=$4
preserve_quality=$5
test_num=0
folder_name=mstcom_${Pr}_${U_ram}_pmffrc_output
save_name=mstcom_${Pr}_${U_ram}_$(basename ${test_files_dir})

### configure C compiler
export compiler=$(which gcc)

### get version code
MAJOR=$(echo __GNUC__ | $compiler -E -xc - | tail -n 1)
MINOR=$(echo __GNUC_MINOR__ | $compiler -E -xc - | tail -n 1)
PATCHLEVEL=$(echo __GNUC_PATCHLEVEL__ | $compiler -E -xc - | tail -n 1)
if [ ${MAJOR} -gt 7 ] && [ ${MAJOR} ]; then
  echo "gcc version: ${MAJOR}.${MINOR}.${PATCHLEVEL}"
else
  echo "gcc -version must great than 8.4.0..."
  echo "yours: ${MAJOR}.${MINOR}.${PATCHLEVEL}"
  exit 0
fi

echo
echo "# 1. make output dir"
echo "  savename: ${save_name}.pmffrc"
echo "  folder_name: ${folder_name}"
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
mstcom_pre_compression() {
  echo "  call mstcom algorithm for pre-compression!"
  mstcomPath=${PMFFRC_PATH}src/mstcom
  cd ${mstcomPath}
  if [ $? -ne 0 ]; then
    echo "mstcom running wrong!"
    exit 0
  fi
  { /bin/time -v -p mstcom-bin e -i ${test_files_dir}/${folder_name}/X1.fastq -o ${test_files_dir}/${folder_name}/X1.mstcom -p -t 8 >${test_files_dir}/${folder_name}/mstcom_X1.drop; } 2>${test_files_dir}/${folder_name}/C1.log
  { /bin/time -v -p mstcom-bin e -i ${test_files_dir}/${folder_name}/X2.fastq -o ${test_files_dir}/${folder_name}/X2.mstcom -p -t 8 >${test_files_dir}/${folder_name}/mstcom_X2.drop; } 2>${test_files_dir}/${folder_name}/C2.log
  echo "  mstcom pre-compressor over"
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
  rm ${test_files_dir}/${folder_name}/X1.mstcom
  if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
  rm ${test_files_dir}/${folder_name}/X2.mstcom
  if [ $? -ne 0 ]; then
    echo "rm files wrong!"
    exit 0
  fi
}

mstcom_pre_compression
a=$(sed -n 15p ${test_files_dir}/${folder_name}/C1.log | tr -cd "[0-9]")
b=$(sed -n 15p ${test_files_dir}/${folder_name}/C2.log | tr -cd "[0-9]")
echo "  X1-Y_cpm: $a KB"
echo "  X2-Y_cpm: $b KB"
echo "  Y_diff: $((b - a)) KB"
echo "  test_num: $test_num Reads"
echo $((b - a)) >> ${test_files_dir}/${folder_name}/X.log
echo $((a)) >> ${test_files_dir}/${folder_name}/X.log
echo >> ${test_files_dir}/${folder_name}/X.log

echo
echo "# 4. clustering"
Beta=0.75
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
mstcom_compressor() {
  echo "***********************"
  files_list=$(ls ${test_files_dir}/${folder_name})
  for tempFile in ${files_list}; do
    echo $tempFile
    if [[ ${tempFile:$((${#tempFile} - 6))} == ".fastq" ]]; then
      echo $tempFile
      base_name=`basename ${tempFile} .fastq`
      echo "  ***********************${tempFile}*************************"
      if [[ ${preserve_quality} == "True" ]]; then
        mstcomPath=${PMFFRC_PATH}src/mstcom
        cd ${mstcomPath}
        mstcom-bin e -i ${test_files_dir}/${folder_name}/${tempFile} -o ${test_files_dir}/${folder_name}/${base_name}.mstcom -p -t 8
      fi
      if [[ ${preserve_quality} == "False" ]]; then
        mstcomPath=${PMFFRC_PATH}src/mstcom
        cd ${mstcomPath}
        mstcom-bin e -i ${test_files_dir}/${folder_name}/${tempFile} -o ${test_files_dir}/${folder_name}/${base_name}.mstcom -p -t 8
      fi
    fi
  done
}
mstcom_compressor

echo
echo "# 7. pack files to *.pmffrc"
mstcom_pack() {
  pwd_p=`pwd`
  cd ${test_files_dir}/${folder_name}
  tar -cf cluster_info.tar *.clu
  tar -Jcf cluster_info.tar *.clu
  tar -cf ${save_name}.pmffrc cluster_info.tar *mstcom
  cp ${save_name}.pmffrc ${test_files_dir}
  cd ${pwd_p}
}
mstcom_pack


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