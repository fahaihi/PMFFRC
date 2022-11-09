#!/bin/bash
# This script is used to download the NCBI dataset,
# We provided you have Sratools installed.
# For Sratools information, see the https://github.com/NCBI/sra-tools

# ILLUMINA
# HiSeq-2000_Cicer_arietinum_PE
# 30*2-Files L=90bp
# SRR13556190-13556217; 220; 224
dir_pwd=`pwd`
head="SRR13556"
data_set_name="HiSeq-2000_Cicer_arietinum_PE"
mkdir ${data_set_name}
cd ${data_set_name}
for index in `seq 190 217`
do
  prefetch ${head}${index}
  fastq-dump --split-files ${head}${index}
  rm -rf ${head}${index}
done

for index in 220 224
do
  prefetch ${head}${index}
  fastq-dump --split-files ${head}${index}
  rm -rf ${head}${index}
done
