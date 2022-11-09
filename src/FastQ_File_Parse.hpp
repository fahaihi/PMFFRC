/* ***********************************************************************
describe: 这个文件用于解析FASTQ文件,分离FASTQ文件中的4个部分
date:20220717
authors:SH
************************************************************************ */

#ifndef FASTQ_FILE_PARSE_HPP
#define FASTQ_FILE_PARSE_HPP

#include<iostream>
#include<fstream>
#include<omp.h>
#include<string>
#include<string.h>
#include<algorithm>
#include<dirent.h>
#include<unistd.h>
#include<sys/stat.h>
#include<sys/stat.h>
#include<sys/types.h>
#include<vector>
using std::string;
using std::endl;
using std::cout;

class FFP{
    private:
        string Parsed_Path_EXT;                    // 解析文件后缀
        string Parsed_Path_NAME;                   // 解析文件名
        string Parsed_Path_PATH;                   // 解析文件路径
        string Source_File_PATH;

        string Saved_BaseSequence_Path;            // 保存序列路径
        string Saved_QualityScore_Path;            // 保存碱基质量得分
        string Saved_DescribeInformation1_Path;    // 保存文件第一行
        string Saved_DescribeInformation2_Path;    // 保存文件第三行

        string Saved_Temp_File;
    public:
        void File_Path_Parse(const std::string& filepath);
        void Debug();
        void Getfilepath(const char *path, const char *filename,  char *filepath);
        bool DeleteFile(const char* path);
        void Input(const std::string& filepath);

};

/* 解析文件路径 */
void FFP::File_Path_Parse(const std::string& filepath){
    //cout << "Parsed-File-Path:" << filepath << endl;
    Source_File_PATH = filepath;
    /*
    if(!filepath.empty()){
        int locpoint = filepath.find_last_of('.');
        int locfilename = filepath.find_last_of('/');
        Parsed_Path_EXT = filepath.substr(locpoint );
        Parsed_Path_NAME = filepath.substr(locfilename + 1, locpoint - locfilename-1);
        Parsed_Path_PATH = filepath.substr(0, locfilename);
    }
    else throw("PARSE_FILE_ERR!"); */

    //  新建文件夹用于解析
    //string CurrDir = getcwd(NULL,0);
    //Saved_Temp_File = CurrDir;// + "/Parsed_Temp_File_" + Parsed_Path_NAME;
    Saved_BaseSequence_Path = Source_File_PATH + ".dna";
    Saved_QualityScore_Path = Source_File_PATH + ".quality";
    Saved_DescribeInformation1_Path = Source_File_PATH + ".id1";
    Saved_DescribeInformation2_Path = Source_File_PATH + ".id2";


}

/* 调试文件信息 */
void FFP::Debug(){

    if(1==2){
        cout << "****************************************" << endl;
        cout << "FFP::Debug()..." <<endl;
        cout << "Parsed_Path_PATH : " << Parsed_Path_PATH << endl;
        cout << "Parsed_Path_NAME : " << Parsed_Path_NAME << endl;
        cout << "Parsed_Path_EXT :  " << Parsed_Path_EXT << endl;
        cout << "Saved_Temp_File :  " << Saved_Temp_File << endl;
        cout << "Saved_DescribeInformation1_Path :  " << Saved_DescribeInformation1_Path << endl;
        cout << "Saved_BaseSequence_Path         :  " << Saved_BaseSequence_Path << endl;
        cout << "Saved_DescribeInformation2_Path :  " << Saved_DescribeInformation2_Path << endl;
        cout << "Saved_QualityScore_Path         :  " << Saved_QualityScore_Path << endl;
        }
}

/* 得到文件路径 */
void FFP::Getfilepath(const char *path, const char *filename,  char *filepath){
        strcpy(filepath, path);
        if(filepath[strlen(path) - 1] != '/')
            strcat(filepath, "/");
        strcat(filepath, filename);
        //printf("path is = %s\n",filepath);
        }

/* 强制删除文件 */
bool FFP::DeleteFile(const char* path){
    DIR *dir;
    struct dirent *dirinfo;
    struct stat statbuf;
    char filepath[256] = {0};
    lstat(path, &statbuf);

    if (S_ISREG(statbuf.st_mode))//判断是否是常规文件
    {
        remove(path);
    }
    else if (S_ISDIR(statbuf.st_mode))//判断是否是目录
    {
        if ((dir = opendir(path)) == NULL)
            return 1;
        while ((dirinfo = readdir(dir)) != NULL)
        {
            Getfilepath(path, dirinfo->d_name, filepath);
            if (strcmp(dirinfo->d_name, ".") == 0 || strcmp(dirinfo->d_name, "..") == 0)//判断是否是特殊目录
            continue;
            DeleteFile(filepath);
            rmdir(filepath);
        }
        closedir(dir);
    }
    return 0;}

/* 函数主要入口 */
void FFP::Input(const std::string& filepath){
    // cout << "FASTQ-FILE-PARSE BEGIN..." << endl;
    File_Path_Parse(filepath);
    std::vector<string>PathList;
    PathList.push_back(Saved_DescribeInformation1_Path);
    PathList.push_back(Saved_BaseSequence_Path);
    PathList.push_back(Saved_DescribeInformation2_Path);
    PathList.push_back(Saved_QualityScore_Path);

    // 新建临时文件夹
    int isDirExist = !access(&Saved_Temp_File[0], F_OK); // 存在返回状态1
    if(isDirExist==1){
        // 删除文件夹
        DeleteFile(&Saved_Temp_File[0]);
        rmdir(&Saved_Temp_File[0]);
    }
    int isCreate = mkdir(&Saved_Temp_File[0], S_IRUSR | S_IWUSR | S_IXUSR | S_IRWXG | S_IRWXO);
    // if(isCreate!=0) std::cout << "Saved_Temp_File_Wrong!" << std::endl;
    #pragma omp parallel num_threads(4)
    {
        int tNum = omp_get_thread_num();
        // 打开原始文件
        std::ifstream inputFiles;
        inputFiles.open(Source_File_PATH, std::ios::in);
        if (!inputFiles) throw("Source_File_Wrong!");

        // 打开写入文件
        string FileName = PathList[tNum];
        std::ofstream outputFiles;
        outputFiles.open(PathList[tNum], std::ios::trunc);
        if(!outputFiles) throw("Saved_File_Wrong!");
        //outputFiles << " hahhaha" << endl;

        // 打开文件开始读取
        string DescribeInformation1;     // 记录FASTQ文件第一行
        string BaseSequence;             // 记录FASTQ文件第二行
        string DescribeInformation2;     // 记录FASTQ文件第三行
        string SequencingQualityFactor;  // 记录FASTQ文件第四行

        while (inputFiles.peek() != EOF){
            getline(inputFiles, DescribeInformation1);
            getline(inputFiles, BaseSequence);
            getline(inputFiles, DescribeInformation2);
            getline(inputFiles, SequencingQualityFactor);
            //std::cout<<BaseSequence.length()<<":"<<BaseSequence<<std::endl;
            if(tNum == 0) outputFiles << DescribeInformation1 << endl;
            if(tNum == 1) outputFiles << BaseSequence << endl;
            if(tNum == 2) outputFiles << DescribeInformation2 << endl;
            if(tNum == 3) outputFiles << SequencingQualityFactor << endl;

        }
        outputFiles.close();
        inputFiles.close();

        //
    };
    // cout << "FASTQ-FILE-PARSE END..." << endl;

}

#endif