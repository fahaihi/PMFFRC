#!/bin/bash
# This script is used to download the NCBI dataset,
# We provided you have Sratools installed.
# For Sratools information, see the https://github.com/NCBI/sra-tools

# dataSet Info:
# ILLUMINA
# NextSeq-550_Homo_sapiens_SE
# 24-Files L=75bp
# NCBI res.num:ERR7091240 1241 1242 1243 1245 1246 1247 1248 1253 1254 1255 1256 1258 1259 1260 1261 1262 1263 1264 1265 1266 1267 1268 1269

dir_pwd=`pwd`
head="ERR709"
data_set_name="NextSeq-550_Homo_sapiens_SE"
mkdir ${data_set_name}
cd ${data_set_name}
for index in 1240 1241 1242 1243 1245 1246 1247 1248 1253 1254 1255 1256 1258 1259 1260 1261 1262 1263 1264 1265 1266 1267 1268 1269
do
  prefetch ${head}${index}
  fastq-dump --split-files ${head}${index}
  rm -rf ${head}${index}
done
