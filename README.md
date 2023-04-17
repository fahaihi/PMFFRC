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
The PMFFRC takes the genomic sequencing Reads compression ratio as the optimization goal. It performs joint clustering compression on the Reads in multiple FastQ files by modeling the system memory, the peak memory overhead of the cascading compressor, the numeral of files, and the numeral of sequencing reads in the actual application scenarios. 

PMFFRC (Parallel Multi-FastQ-Files Reads Clustering).

## Copy Our Project

Firstly, clone our tools from GitHub:
```shell script
git clone https://github.com/fahaihi/PMFFRC.git
```
Secondly, turn to PMMFRC directory：
```shell script
cd PMFFRC
```
Thirdly, Run the following command：
```shell script
chmod +x install.sh
./install.sh
```
Finally, Configure the environment variables with the following command:
```shell script
export PATH=$PATH:`pwd`/
export PMFFRC_PATH="`pwd`/"
source ~/.bashrc
```
Warning!: PMFFRC relies on `/bin/time` memory and time evaluation commands, make sure 
that running the following Linux command produces the correct results before using PMFFRC.
```shell script
/bin/time -v -p echo "hello pmffrc"
```
If "/usr/bin/time: No such file or directory" is displayed, make sure you have sudo permission to run the following command:
```shell script
sudo yum install time
```
## Usage
PMFFRC algorithm scripts currently only support `HARC (2018)`, `Spring (2019)`, `FastqCLS (2021)`, and `MSTCOM (2022)` algorithms. To run `./PMFFRC`, please configure the file script in the `PMFFRC/src/*_compressor.sh` and `PMFFRC/src/*_decompressor.sh` directory. 

The detailed configuration scripts for the four dedicated compressors are as follows:
#### HARC compressor
Install and configure the HARC compressor firstly.
```shell script
cd src
git clone https://github.com/shubhamchandak94/HARC.git 
cd HARC
chmod +x install.sh
./install.sh
``` 
Next, run the following script to check whether HARC is installed successfully.
```shell script
./harc -c ${PMFFRC_PATH}data/SRR11995098_test.fastq -p -t 8
```
Finally, switch to the following file directory and check if there is a `SRR11995098_test.harc` compressed file.
```shell script
cd ${PMFFRC_PATH}data
```
Note: The HARC compressor depends on 7z, if the run shows './harc: line 104: 7z: command not found', make sure you have sudo permission to run the following command:
```shell script
sudo yum install p7zip p7zip-plugins
```
#### SPRING compressor
Install and configure the SPRING compressor firstly.
```shell script
cd ${PMFFRC_PATH}src
git clone https://github.com/shubhamchandak94/SPRING.git 
``` 
On Linux with cmake installed and version at least 3.9 (check using `cmake --version`):
```shell script
cd SPRING
mkdir build
cd build
cmake ..
make
```
On Linux with cmake not installed or with version older than 3.12:
```shell script
cd SPRING
mkdir build
cd build
wget https://cmake.org/files/v3.12/cmake-3.12.4.tar.gz
tar -xzf cmake-3.12.4.tar.gz
cd cmake-3.12.4
./configure
make
cd ..
./cmake-3.12.4/bin/cmake ..
make
```
Next, run the following script to check whether SPRING is installed successfully.
```shell script
./spring -c -i ${PMFFRC_PATH}data/SRR11995098_test.fastq -o ${PMFFRC_PATH}data/SRR11995098_test.spring
```
Finally, switch to the following file directory and check if there is a `SRR11995098_test.spring` compressed file.
```shell script
cd ${PMFFRC_PATH}data
```
#### MSTCOM compressor
Install and configure the Mstcom compressor firstly.
```shell script
cd ${PMFFRC_PATH}src
git clone https://github.com/yuansliu/mstcom.git 
cd mstcom
make
``` 
Next, run the following script to check whether MSTCOM is installed successfully.
```shell script
./mstcom e -i ${PMFFRC_PATH}data/SRR11995098_test.fastq -o ${PMFFRC_PATH}data/SRR11995098_test.mstcom
```
Finally, switch to the following file directory and check if there is a `SRR11995098_test.mstcom` compressed file.
```shell script
cd ${PMFFRC_PATH}data
```
#### FastcCLS compressor
notes: 

(a) FastqCLS compressor entire FastQ file, we changed the FastqCLS script only for Reads compression, 
FastqCLS located in `src/fastqcls`. 

(b) The FastqCLS relies on the zpaq compressor, if your device is not configured with zpaq, download and install zpaq firstly.

(c) The FastqCLS compressor relies on Python scripts, and you need to install Python on your system.

#### RUN PMFFRC
After configuring the `PMFFRC/src/*_compressor.sh` and `PMFFRC/src/*_decompressor.sh` files, run `PMFFRC` with the following command:
```sh
Compression-> Compress Multi-FastQ Files:
    PMFFRC [-c multi-fastQ-files-path]
           [-y cascading algorithm used. "harc"]
           [-t num_threads. --Default=20]
           [-u user_defined_ram_size. --Default 10GB]
           [-q write quality values and read ids to .quality && .id files]
           [-e clean temp files. --Default "false"]
           
DECompression-> DECompress Multi-FastQ Files:
    PMFFRC [-d *.pmffrc format file]
           [-e clean temp files. --Default "false"]
           
Help (this message):
    PMFFRC -h
```
notes：In the PMFFRC toolkit, the parameters beta, x1, and x2 are initialized in the *compressor script. The BIOCONDA version will be updated soon...


## Examples
We present the validation dataset under the `PMFFRC/data/testData` directory, which consists of 12 real FastQ sequencing files, each approximately 100MB.
The following are some examples of compression using PMFFRC cascading different compressors:
### Examples 1: Optimize HARC compression
#### 1、Using 10GB of system memory, using 2 CPU cores clustering, select harc as the base compressor.
```sh
cd data
PMFFRC -c testData -y harc -t 2 -u 10 -q -e
```
Note: If the algorithm runs incorrectly, it may be a problem that the cascading algorithm environment depends on, 
please check the `testData/harc_2_10_pmffrc_output/C1.log` file to view the specific error information.
#### 2、Unzip the compressed file generated by PMFFRC from harc.
```sh
cd testData
PMFFRC -d harc_2_10_testData.pmffrc -y harc
# The extracted files are located in the following file directories:
# *testData/de_harc_2_10_testData
```
### Examples 2: Optimize SPRING compression
#### 1、Using 2GB of system memory, using 4 CPU cores clustering, select spring as the base compressor.
```sh
cd data
PMFFRC -c testData -y spring -t 4 -u 2
```
#### 2、Unzip the compressed file generated by PMFFRC from spring.
```sh
cd testData
PMFFRC -d spring_4_2_testData.pmffrc -y spring
# The extracted files are located in the following file directories:
# *testData/spring_4_2_testData
```
#### 3、An example demo of optimizing spring compressor is shown here:
DEMO URL: https://www.youtube.com/embed/aB1SvhCh7ww?start=1
[![pmffrc demo](https://github.com/fahaihi/PMFFRC/blob/master/DEMO.png)](https://www.youtube.com/embed/aB1SvhCh7ww?start=1 "PMFFRFC-DEMO")

## Our Experimental Configuration
Our experiment was conducted on the SUGON-7000A supercomputer system at the Nanning Branch of the National Supercomputing Center, using a queue of CPU/GPU heterogeneous computing nodes. The compute nodes used in the experiment were configured as follows: 
  
  2\*Intel Xeon Gold 6230 CPU (2.1Ghz, total 40 cores), 
  
  2\*NVIDIA Tesla-T4 GPU (16GB CUDA memory, 2560 CUDA cores), 
  
  512GB DDR4 memory, and 
  
  8\*900GB external storage.

## Dataset Acquisition
We experimentally evaluated using the real publicly available sequencing datasets from the NCBI database, Homo sapiens (智人), Cicer arietinum (鹰嘴豆), and Salvelinus fontinalis (美洲红点鲑).

1、For the Homo sapiens dataset, we randomly selected the following registration numbers:
ERR7091240-1243;1245-1248; 1253-1256;1258-1269 (24 SE-Files).

download this dataset by the following command:
```sh
bash data/NextSeq-550_Homo_sapiens_SE.sh
```
2、For the Cicer arietinum dataset, we randomly selected the following registration numbers:
SRR13556190-13556217;220;224 (60 PE-Files).

download this dataset by the following command:
```sh
bash data/HiSeq-2000_Cicer_arietinum_PE.sh
```
3、For the Salvelinus fontinalis dataset, we randomly selected the following registration numbers:
SRR11994925-SRR11995284 (360 SE-Files).

download this dataset by the following command:

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
**Source-Version：**    V1.2022.10.14. V2.2023.02.26.

**Latest-Version：**    V2.1.2023.04.17.

**Authors:**     NBJL-BioGrop.

**Contact us:**  https://nbjl.nankai.edu.cn OR sunh@nbjl.naikai.edu.cn
