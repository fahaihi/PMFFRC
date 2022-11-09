# PMFFRC 
![made-with-C++](https://img.shields.io/badge/Made%20with-C++11-brightgreen)
![made-with-OpenMP](https://img.shields.io/badge/Made%20with-OpenMP-blue)

<!-- LOGO -->
<br />
<h1>
<p align="center">
  <img src="https://github.com/fahaihi/PMFFRC/blob/master/Log.png" alt="Logo" width="722" height="189">
</h1>
  <p align="center">
    A Parallel Multi-FastQ-Files Reads Clustering Tool For Improving DNA Reads Compression.
    </p>
</p>
<p align="center">
  <a href="#about-the-pmffrc">About The Pmffrc</a> •
  <a href="#copy-our-project">Copy Our Project</a> •
  <a href="#useage">Useage</a> •
  <a href="#example">Example</a> •
  <a href="#our-experimental-configuration">Our Experimental Configuration</a> •
    <a href="#dataset-acquisition">Dataset Acquisition</a> •
  <a href="#aknowledgements">Acknowledgements</a> •
</p>  

<p align="center">
  
![screenshot](img/clip.gif)
</p>                                                                                                                             
                                                                                                                                                      
## About The PMFFRC 
The PMFFRC algorithm takes the genomic sequencing Reads compression rate as the optimization goal, and performs joint clustering compression on the Reads in multiple FastQ files by modeling the system memory, the peak memory overhead of the cascading algorithm, the number of files and the number of sequences in the practical application scenarios of the compression algorithm. 
PMFFRC (Parallel Multi-FastQ-Files Reads Clustering).

## Copy Our Project

firstly, clone our tools from GitHub:
```sh
git clone https://github.com/fahaihi/PMFFRC.git
```
secondly, turn to PMMFRC directory：
```sh
cd PMFFRC
```
finally, Run the following command：
```
bash install.sh
```
## Usage
PMFFRC algorithm scripts currently only support `HARC (2018)`, `Spring (2019)`, `FastqCLS (2021)`, and `MSTCOM (2022)` algorithms. To run `./PMFFRC`, please configure the file script in the `PMFFRC/src/*_compressor.sh` and `PMFFRC/src/*_decompressor.sh` directory. 
`HARC (2018)`, `Spring (2019)`, `FastqCLS (2021)` and `MSTCOM (2022)` configurations please refer to the following repositories:
```sh
  HARC(2018)：https://github.com/shubhamchandak94/HARC
  Spring(2019)：https://github.com/shubhamchandak94/Spring
  MSTCOM(2021)：https://github.com/yuansliu/mstcom
  FastqCLS(2022)：https://github.com/Krlucete/FastqCLS 
```
After configuring the `PMFFRC/src/*_compressor.sh` and `PMFFRC/src/*_decompressor.sh` files, run `./PMFFRC` with the following command:
```sh
Compression-> Compress Multi-FastQ Files:
  ./PMFFRC [-c multi-fastQ-files-path]
           [-y cascading algorithm used. "harc"]
           [-t num_threads. --Default=20]
           [-u user_defined_ram_size. --Default 10GB]
           [-q write quality values and read ids to .quality && .id files]
           [-e clean temp files. --Default "false"]
           
DECompression-> DECompress Multi-FastQ Files:
  ./PMFFRC [-d *.pmffrc format file]
           [-t num_threads. --Default=20]
           [-e clean temp files. --Default "false"]
           
Help (this message):
  ./PMFFRC -h
```

## Examples
1、Compress multiple files in the /userdir/data/testdir directory using 20 CPU cores and 40GB of secure memory：
```sh
./PMFFRC -c /userdir/data/testdir -y harc -t 20 -u 40 -q -e
```
2、If you don't want to save `*.quality`, `*.id`, and `* temp files`, you can run the following command：
```sh
./PMFFRC -c /userdir/data/testdir -y harc -t 20 -u 40
```
3、DeCompress the /userdir/data/testdir.pmffrc file using 20 CPU cores while keeping the intermediate result file:
```sh
./PMFFRC -d /userdir/data/testdir.pmffrc -y harc -t 20
```
4、Print help information:
```sh
./PMFFRC -h
```

## Our Experimental Configuration
Our experiment was conducted on the Dawning 7000A supercomputer system at the Nanning Branch of the National Supercomputing Center, using a queue of CPU/GPU heterogeneous computing nodes. The compute nodes used in the experiment were configured as follows: 
  2\*Intel Xeon Gold 6230 CPU (2.1Ghz, total 40 cores), 
  2\*NVIDIA Tesla-T4 GPU (16GB of cuda memory, 2560 CUDA cores), 
  512GB DDR4 memory, and 
  8\*900GB external storage.

## Dataset Acquisition
We experimentally evaluated using the real publicly available sequencing datasets from the NCBI database, Homo sapiens (智人), Cicer arietinum (鹰嘴豆), and Salvelinus fontinalis (美洲红点鲑).

1、For the Homo sapiens dataset, we randomly selected the following registration numbers:
ERR7091240-1243;1245-1248; 1253-1256;1258-1269 (24 SE-Files)
You can download this dataset by the following command:
```sh
bash data/NextSeq-550_Homo_sapiens_SE.sh
```
2、For the Cicer arietinum dataset, we randomly selected the following registration numbers:
SRR13556190-13556217;220;224 (60 PE-Files).
You can download this dataset by the following command:
```sh
bash data/HiSeq-2000_Cicer_arietinum_PE.sh
```
3、For the Salvelinus fontinalis dataset, we randomly selected the following registration numbers:
SRR11994925-SRR11995284 (360 SE-Files).
You can download this dataset by the following command:

```sh
bash data/Ion-Torrent_Salvelinus_fontinalis_SE.sh
```
Dataset download and extraction using the `SRA-Tools：https://github.com/ncbi/sra-tools tool`.

## Acknowledgements
- Thanks to [@HPC-GXU](https://hpc.gxu.edu.cn) for the computing device support.   
- Thanks to [@NCBI](https://www.freelancer.com/u/Ostokhoon) for all available datasets.
- Thanks to [@HARC-Project](https://github.com/shubhamchandak94/HARC) for HARC source code.
- Thanks to [@SPRING-Project](https://github.com/shubhamchandak94/Spring) for Spring source code.
- Thanks to [@MSTCOM-Project](https://github.com/yuansliu/mstcom) for MSTCOM source code.
- Thanks to [@FASTQCLS-Project](https://github.com/Krlucete/FastqCLS) for FastqCLS source code.

## Additional Information
**Version：**    V1.2022.10.14.
**Authors:**     NBJL-BioGrop.
**Contact us:**  https://nbjl.nankai.edu.cn OR sunh@nbjl.naikai.edu.cn
