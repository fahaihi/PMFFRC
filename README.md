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
  <a href="#best-practice">Best Practice</a> •
  <a href="#credits">Credits</a> •
  <a href="examples.md">More Examples</a>
</p>  

<p align="center">
  
![screenshot](img/clip.gif)
</p>                                                                                                                             
                                                                                                                                                      
## About The PMFFRC 
The PMFFRC algorithm takes the DNA sequencing Reads compression rate as the optimization goal, and performs joint clustering compression on the Reads in multiple FastQ files by modeling the system memory, the peak memory overhead of the cascading algorithm, the number of files and the number of sequences in the practical application scenarios of the compression algorithm. PMFFRC(Parallel Multi-FastQ-Files Reads Clustering).

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
           [-y cascading. "harc"]
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

## Best Practice
Colab has wildly varying transfer speeds, because of this, the best we can offer are suggestions:
- For large groups of medium/small files, 15-40 threads seems to work best.
- For 50+ files with significantly varying sizes, try 2 sequentially copies. `-t 15 -l 400` then `-t 2`
- For files that are 100MB+, it is best to use 2 threads. It is still faster then rsync.   
- Currently `--sync` breaks if rsync is ran after. If you are mirroring drives. Disable `--sync` and use the rsync's `--delete` function.

## Credits
- Credit to [ikonikon](https://github.com/ikonikon/fast-copy) for the base multi-threading code.   
- Thanks to [@Ostokhoon](https://www.freelancer.com/u/Ostokhoon) for ALL argument and folder hierarchy functionality.
