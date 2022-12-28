#!/bin/bash
g++ src/multi_fastq_files_reads_clustering.cpp -std=c++11 -fopenmp -O3 -o src/multi_fastq_files_reads_clustering.out
g++ src/test_FFP.cpp -O3 -march=native -fopenmp -std=c++11 -o src/test_FFP.out
chmod +x src/harc_compressor.sh
chmod +x src/harc_decompressor.sh
chmod +x src/spring_compressor.sh
chmod +x src/spring_decompressor.sh
chmod +x src/fastqcls_compressor.sh
chmod +x src/fastqcls_decompressor.sh
chmod +x src/mstcom_compressor.sh
chmod +x src/mstcom_decompressor.sh
chmod +x data/NextSeq-550_Homo_sapiens_SE.sh
chmod +x data/HiSeq-2000_Cicer_arietinum_PE.sh
chmod +x data/Ion-Torrent_Salvelinus_fontinalis_SE.sh
