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

firstly, clone our tools from GitHub:
```shell script
git clone https://github.com/fahaihi/PMFFRC.git
```
secondly, turn to PMMFRC directory：
```shell script
cd PMFFRC
```
thirdly, Run the following command：
```shell script
chmod +x install.sh
./install.sh
```
finally, Configure the environment variables with the following command:
```shell script
export PATH=$PATH:`pwd`/
export PMFFRC_PATH="`pwd`/"
source ~/.bashrc
```
## Usage
PMFFRC algorithm scripts currently only support `HARC (2018)`, `Spring (2019)`, `FastqCLS (2021)`, and `MSTCOM (2022)` algorithms. To run `./PMFFRC`, please configure the file script in the `PMFFRC/src/*_compressor.sh` and `PMFFRC/src/*_decompressor.sh` directory. 
`HARC (2018)`, `Spring (2019)`, `FastqCLS (2021)` and `MSTCOM (2022)` .

The detailed configuration scripts for the four dedicated compressors are as follows:
#### A. HARC compressor
```shell script
# Install and configure the HARC compressor firstly.
cd src
git clone https://github.com/shubhamchandak94/HARC.git # --config "http.proxy=127.0.0.1:7890"
cd HARC
chmod +x ./install.sh
./install.sh
# Next, run the following script to check whether HARC is installed successfully.
./harc -c ${PMFFRC_PATH}data/testData/SRR11994936_1_1.fastq -p -t 8

``` 
note: HARC relies on the 7Z compressor, if your device is not configured with 7Z, download and install 7Z firstly.
#### SPRING compressor
```shell script
cd src
git clone https://github.com/shubhamchandak94/Spring.git #--config "http.proxy=127.0.0.1:7890"
cd Spring
mkdir build
cd build
cmake ..
``` 
#### MSTCOM compressor
```shell script
cd src
git clone https://github.com/yuansliu/mstcom.git #--config "http.proxy=127.0.0.1:7890"
cd mstcom
make
``` 
notes: The MSTCOM compressor requires gcc>8.
#### FastcCLS compressor
notes: 

(a) FastqCLS compressor entire FastQ file, we changed the FastqCLS script only for Reads compression, 
FastqCLS located in `src/fastqcls`. 

(b) The FastqCLS relies on the zpaq compressor, if your device is not configured with zpaq, download and install zpaq firstly.

(c) The FastqCLS compressor relies on Python scripts, and you need to install Python on your system.

#### One-click configuration
We give the one-click configuration scripts for the above four specialized compressors by running the following command:
```shell script
cd src
chmod +x config.sh
./config.sh
```

#### RUN PMFFRC
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
           [-e clean temp files. --Default "false"]
           
Help (this message):
  ./PMFFRC -h
```
note：In the PMFFRC toolkit, the parameters beta, x1, and x2 are initialized in the *compressor script.


## Examples
We present the validation dataset under the `PMFFRC/data/testData` directory, which consists of 12 real FastQ sequencing files, each approximately 100MB.
The following are some examples of compression using PMFFRC cascading different compressors:
#### 1、Using 10GB of system memory, using 20 CPU cores clustering, select harc as the base compressor.
```sh
cd data
PMFFRC -c testData/ -y harc -t 20 -u 10 -q -e
```
Note: If the algorithm runs incorrectly, it may be a problem that the cascading algorithm environment depends on, 
please check the `testData/harc_20_10_pmffrc_output/C1.log` file to view the specific error information.
#### 2、Unzip the compressed file generated by PMFFRC from harc.
```sh
cd testData
PMFFRC -d harc_20_10_testData.pmffrc -y harc
# The extracted files are located in the following file directories:
*testData/de_harc_20_10_testData
```
#### 3、Using 2GB of system memory, using 4 CPU cores clustering, select spring as the base compressor.
```sh
cd data
PMFFRC -c testData/ -y spring -t 4 -u 2
```
#### 4、Unzip the compressed file generated by PMFFRC from spring.
```sh
cd testData
PMFFRC -d spring_4_2_testData.pmffrc -y spring
# The extracted files are located in the following file directories:
*testData/spring_4_2_testData
```

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
**Source-Version：**    V1.2022.10.14.

**Latest-Version：**    V2.2023.02.26.

**Authors:**     NBJL-BioGrop.

**Contact us:**  https://nbjl.nankai.edu.cn OR sunh@nbjl.naikai.edu.cn
