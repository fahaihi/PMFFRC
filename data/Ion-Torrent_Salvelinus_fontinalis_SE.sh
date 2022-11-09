#!/bin/bash
# This script is used to download the NCBI dataset,
# We provided you have Sratools installed.
# For Sratools information, see the https://github.com/NCBI/sra-tools

# dataSet Info:
# Ion-Torrent
# Ion-Torrent_Salvelinus_fontinalis_SE
# 360-Files L=80bp
# NCBI res.num:SRR11994925-SRR11995284

dir_pwd=`pwd`
head="SRR1199"
data_set_name="Ion-Torrent_Salvelinus_fontinalis_SE"
mkdir ${data_set_name}
cd ${data_set_name}
for index in `seq 4925 5284`
do
  prefetch ${head}${index}
  fastq-dump --split-files ${head}${index}
  rm -rf ${head}${index}
done
