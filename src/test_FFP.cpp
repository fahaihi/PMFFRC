#include<iostream>
#include<string.h>
#include"FastQ_File_Parse.hpp"
using namespace std;
int main(int argc, char** argv){
    string A = std::string(argv[1]);
    //string A = "/public/home/jd_sunhui/genCompressor/Data/110902_I244_FCC02FUACXX_L4_006SCELL03AEAAAPEI-12/110902_I244_FCC02FUACXX_L4_006SCELL03AEAAAPEI-12_2.fq";
    //string A = "/public/home/jd_sunhui/genCompressor/Data/NCBI/PhiX/PhiX_12.fastq";
    FFP *ffp = new FFP();
    ffp->Input(A);
    ffp->Debug();
    return 0;
}