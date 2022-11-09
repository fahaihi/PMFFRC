/* *******************************************************************
author:SH
date:2022/10/06
describe:a cpp files for generating clustering files for multi-fastq files
g++ multi_fastq_files_reads_clustering.cpp -std=c++11 -fopenmp -O3 -o multi_fastq_files_reads_clustering.out
./multi_fastq_files_reads_clustering.out /public/home/jd_sunhui/genCompressor/Data/MgiSeq-2000RS_Mus-musculus_PE
******************************************************************** */
#include<bits/stdc++.h>
#include<omp.h>
#include<dirent.h>
#include<fstream>
#include<cstdlib>
#include<cmath>
using namespace std;

// a data struct for file_node
typedef struct file_node{
    string name;
    uint32_t reads_num;
    vector<int> feature;
}File_Node;
vector<file_node*>files_node_list;

// a data struct for calculating files-sim
typedef struct sim_node{
    string file_name_A, file_name_B;
    uint32_t reads_num_A, reads_num_B;
    float sim;
    sim_node(){
        file_name_A = "";
        file_name_B = "";
        reads_num_A = 0;
        reads_num_B = 0;
        sim = 0;
    }
}Sim_Node;
vector<sim_node*>sim_node_list;

uint64_t total_reads_num = 0;
uint64_t total_reads_num_copy = 0;
uint64_t average_reads_num = 15000000;
vector<string>files_name_list;
int read_length = 0;
int random_model_flag = 0;
int debug_model = 1;
int cluster_num_k1 = 2;       // calculated cluster num
int cluster_num_k2 = 0;       // fixed cluster num
int files_num = 0;
int test_reads_num;
int thread_num = 8;
float Y_cpm;             // KB
float U_ram = 20;              // GB
float beta = 1.05;
float Y_size = 0;
vector<int>read_length_list;
string input_files_dir;
string output_files_dir;
string output_folder = "/pmffrc_output/";
string X_path = "/pmffrc_output/X.log";

void get_files(std::string path, std::vector<std::string> &files_name_list);
void get_parameter_k1();
void func_random_model_1();
void cluster();
int get_files_node_list();
void get_sim_node_list();
float DiceIndex(vector<int>nums1, vector<int>nums2);
int descending_reorder(vector<sim_node*>&nums, int begin, int end);
int get_Xinfo();

int main(int argc, char** argv){

    if(debug_model) cout<< "  1 begin to multi-fastq files clustering algorithms!" << endl;
    input_files_dir = std::string(argv[1]);
    thread_num = atoi(argv[2]);
    U_ram = atof(argv[3]);
    output_folder = "/" + std::string(argv[4]) + "/";
    beta =atof(argv[5]);
    if(debug_model) cout << "  beta:" << beta << endl;
    X_path = output_folder + "X.log";
    output_files_dir = input_files_dir + output_folder;


    get_files(input_files_dir, files_name_list);
    files_num = files_name_list.size();
    if(!get_Xinfo()) cout << "  get Y_cpm Wrong!" << endl;


    if(get_files_node_list()==0) {cout << "  get files node list wrong!" << endl; return 0;}
    if(debug_model) cout<< "  2 get files node list over!" << endl;
    get_parameter_k1();
    cout << "  K1: " << cluster_num_k1 << endl;
    if(debug_model) cout<< "  3 get parameter K1 over!" << endl;


    get_sim_node_list();
    if(debug_model) cout << "  4 get sim list over!" << endl;

    if(debug_model) cout << "  begin to descending_reorder!" << endl;
    if(debug_model) cout << "  sim_node_list.size() : " << sim_node_list.size() << endl;
    descending_reorder(sim_node_list, 0, sim_node_list.size()-1);
    if(debug_model) cout << "  descending_reorder over!" << endl;
    //for(int i=0; i<sim_node_list.size(); i++){
    //    cout << sim_node_list[i]->sim << endl;
    //    cout << sim_node_list[i]->reads_num_A << " : " << sim_node_list[i]->file_name_A << endl;
    //    cout << sim_node_list[i]->reads_num_B << " : " << sim_node_list[i]->file_name_B << endl;
    //}



    cluster();
    if(debug_model) cout <<"  5 cluster over!" << endl;
    if(debug_model){
        cout << "  average_reads_num: " << average_reads_num << endl;
        cout << "  total_reads_num:  "<< total_reads_num << endl;
        cout << "  Y_cpm: " << Y_cpm << endl;
        cout << "  U_ram: " << U_ram << endl;
        cout << "  files num: " << files_num << endl;
        cout << "  cluster k1: " << cluster_num_k1 << endl;
        cout << "  cluster k2: " << cluster_num_k2 << endl;
    }

    return 0;
}

void get_files(std::string path, std::vector<std::string> &files_name_list) {
    DIR *dir;
    struct dirent *ptr;
    if ((dir = opendir(path.c_str())) == NULL) {
        perror("Open dir error...");
        return;
    }

    while ((ptr = readdir(dir)) != NULL) {
        if (strcmp(ptr->d_name, ".") == 0 || strcmp(ptr->d_name, "..") == 0)    ///current dir OR parrent dir
            continue;
        else if (ptr->d_type == 8)    ///file
        {
            std::string strFile;
            std::string strFilesub;
            strFile = path;
            strFile += "/";
            strFile += ptr->d_name;
            string::size_type idx, idx1;
            strFilesub = strFile.substr(strFile.length()-7, strFile.length());
            idx = strFilesub.find(".fastq");
            idx1 = strFilesub.find(".fq");
            if((idx != string::npos) || (idx1 != string::npos))
                files_name_list.push_back(strFile);
        } else {
            continue;
        }
    }
    closedir(dir);
}
void get_parameter_k1(){
    Y_cpm = Y_cpm/test_reads_num;   // 单条序列的内存
    //cout << "***********" << Y_cpm << endl;
    cluster_num_k1 = ceil(beta*total_reads_num*Y_cpm/(1024*1024*U_ram - Y_size));
    average_reads_num = floor(total_reads_num/cluster_num_k1);
    //cout << "***********" << average_reads_num << endl;
}
void func_random_model_1(){}
void cluster(){
    int k_flag = 0;
    int files_num_flag = 0;
/*
    if(total_reads_num <= average_reads_num){
        // pack to compress
        cluster_num_k2++;
        string name = output_files_dir + "cluster_0.clu";
        ofstream ofs;
        ofs.open(name);
        ofs << k_flag << "\n";
        // ofs << total_reads_num << "\n";
        ofs << files_node_list.size() << "\n";
        for(int i=0; i<files_node_list.size(); i++){
            ofs << files_node_list[i]->name << "\n";
            ofs << files_node_list[i]->reads_num << "\n";
        }
        ofs.close();
        if(debug_model){
            cout << "  cluster_0" << "  over! ********************************************" << endl;
            cout << "  reads number: " << total_reads_num << endl;
            cout << "  files number: " << files_name_list.size() << endl;
            cout << "  temp files number: " << files_name_list.size() << endl;
            for(int i=0; i<files_name_list.size(); i++){
            cout << "  " << files_name_list[i] << "\n";
            }
            cout << endl;
        }
        flag = 0;
    }
*/
    while(sim_node_list.size()!=0 || files_num_flag!=files_num){ // 单独处理剩余的1和节点
        // 判断整体数量是否小于average number, 或者具有奇数文件
        uint64_t cluster_reads_num = 0;
        for(int i=0; i<files_node_list.size(); i++) cluster_reads_num = cluster_reads_num + files_node_list[i]->reads_num;
        if((cluster_reads_num <= average_reads_num) || (files_node_list.size() <=3)){
            //cout << "  (cluster_reads_num <= average_reads_num) || (files_node_list.size() <=3) " << endl;
            ofstream ofs;
            output_files_dir = input_files_dir + output_folder + "cluster_" + to_string(k_flag) + ".clu";
           // cout << output_files_dir << endl;
            ofs.open(output_files_dir);
            ofs << k_flag << "\n";
            ofs << files_node_list.size() << "\n";
            for(int i=0; i<files_node_list.size(); i++){
                ofs << files_node_list[i]->name << "\n";
                ofs << files_node_list[i]->reads_num << "\n";
            }
            if(debug_model){
                cout << "  cluster_" << k_flag << "  over! ********************************************" << endl;
                cout << "  reads number: " << cluster_reads_num << endl;
                cout << "  average_reads_num: " << average_reads_num << endl;
                cout << "  files number: " << files_node_list.size() << endl;
                cout << "  temp files number: " << files_num_flag + files_node_list.size() << endl;
                for(int i=0; i<files_node_list.size(); i++) {
                    cout << "  " << files_node_list[i]->name << "\n";
                    //cout << files_node_list[i]->reads_num << "\n";
                }
                cout << endl;
            }
            sim_node_list.resize(0);
            cluster_num_k2++;k_flag++;
            files_num_flag = files_num_flag + files_node_list.size();
            break;
        }
        // 相当于上面的if的else
        cluster_reads_num = 0;
        int cycle_flag = 0;
        set<string>temp;
        temp.insert(sim_node_list[0]->file_name_A);
        temp.insert(sim_node_list[0]->file_name_B);
        cluster_reads_num =  sim_node_list[0]->reads_num_A + sim_node_list[0]->reads_num_B;
        for(int i=1; i<sim_node_list.size(); i++){
            if((cycle_flag == 1) || cluster_reads_num >= average_reads_num){ // 说明头两个文件就超限了
                ofstream ofs;
                output_files_dir = input_files_dir + output_folder + "cluster_" + to_string(k_flag) + ".clu";
                ofs.open(output_files_dir);
                ofs << k_flag << "\n";
                ofs << temp.size() << "\n";
                for(set<string>::iterator j=temp.begin(); j!=temp.end(); j++){ // 遍历输出
                    string name = *j;
                    for(int i_=0; i_<files_node_list.size(); i_++){
                        if(files_node_list[i_]->name == name){
                            ofs << files_node_list[i_]->name << "\n";
                            ofs << files_node_list[i_]->reads_num << "\n";
                            files_node_list.erase(files_node_list.begin() + i_);
                        }
                    }
                }
                ofs.close();
                files_num_flag = files_num_flag + temp.size();
                if(debug_model){
                    cout << "  cluster_" << k_flag << "  over! ********************************************" << endl;
                    cout << "  reads number: " << cluster_reads_num << endl;
                    cout << "  average_reads_num: " << average_reads_num << endl;
                    cout << "  files number: " << temp.size() << endl;
                    cout << "  temp files number: " << files_num_flag << endl;
                    for(set<string>::iterator j=temp.begin(); j!=temp.end(); j++) cout << "  " << *j << endl;
                    cout << endl;
                }
                cluster_num_k2++;k_flag++;
                break;
            }
            auto it1 = temp.find(sim_node_list[i]->file_name_A);
            auto it2 = temp.find(sim_node_list[i]->file_name_B);
            if (it1!=temp.end() && it2!=temp.end()) continue;  // 头部节点情况
            else{  // 除头部节点之外的情况
                if(it1!=temp.end() && ((sim_node_list[i]->reads_num_B + cluster_reads_num) >= average_reads_num)){
                    cycle_flag = 1;
                    continue;
                }
                else if(it1!=temp.end() && ((sim_node_list[i]->reads_num_B + cluster_reads_num) < average_reads_num)){
                    cluster_reads_num = cluster_reads_num + sim_node_list[i]->reads_num_B;
                    temp.insert(sim_node_list[i]->file_name_B);
                }
                else if(it2!=temp.end() && ((sim_node_list[i]->reads_num_A + cluster_reads_num) >= average_reads_num)){
                    cycle_flag = 1;
                    continue;
                }
                else if(it2!=temp.end() && ((sim_node_list[i]->reads_num_A + cluster_reads_num) < average_reads_num)){
                    cluster_reads_num = cluster_reads_num + sim_node_list[i]->reads_num_A;
                    temp.insert(sim_node_list[i]->file_name_A);
                }
                else continue;
            }

        }
        // erase node
        int i=0;
        while(i != sim_node_list.size()){
            auto it1 = temp.find(sim_node_list[i]->file_name_A);
            auto it2 = temp.find(sim_node_list[i]->file_name_B);
            if(it1!=temp.end() || it2!=temp.end()) sim_node_list.erase(sim_node_list.begin()+i);
            else i++;
        }

    }
/*
    if(files_node_list.size()!=0{
        // single file
        ofstream ofs;
        output_files_dir = input_files_dir + output_folder + "cluster_" + to_string(k_flag) + ".clu";
        ofs.open(output_files_dir);
        int nums = 0;
        //for(int i=0; i<files_name_list.size(); i++) nums = nums + files_name_list[i]->reads_num;
        ofs << k_flag << "\n";
        ofs << nums << "\n";
        ofs << files_name_list.size() << "\n";
        for(int i=0; i<files_node_list.size(); i++){
            ofs << files_node_list[i]->name << "\n";
            ofs << files_node_list[i]->reads_num<< "\n";
        }

        ofs.close();
        files_num_flag = files_num_flag + files_name_list.size();
        if(debug_model){
            cout << "  cluster_" << k_flag << "  over! ********************************************" << endl;
            cout << "  reads number: " << files_node_list[0]->reads_num << endl;
            cout << "  files number: " << 1 << endl;
            cout << "  temp files number: " << files_num_flag << endl;
            for(int i=0; i<files_name_list.size(); i++)
                cout << files_node_list[i]->name << "\n";
            cout << endl;
        }
        k_flag++; cluster_num_k2++;

    }
*/

}
int get_files_node_list(){
    #pragma omp parallel for num_threads(thread_num)
    for(int i=0; i<files_num; i++){
        int reads_num = 0;
        int read_len = 0;
        ifstream ifs;
        ifs.open(files_name_list[i], std::ios::in);
        string line;
        int j = 0;
        int base_count[4] = {0, 0, 0, 0};
        file_node *node = new file_node();
        while(getline(ifs, line)){
            switch(j){
                case 0: break;
                case 1: if(1){
                    if(read_len==0){ read_len = line.length(); read_length_list.push_back(read_len);}
                    if(1){
                        reads_num++;
                        base_count[0] = 0; base_count[1] = 0; base_count[2] = 0; base_count[3] = 0;
                        for(int k=0; k<read_len; k++){
                            if(line[k]=='A') base_count[0]++;
                            if(line[k]=='C') base_count[1]++;
                            if(line[k]=='G') base_count[2]++;
                            if(line[k]=='T') base_count[3]++;
                        }
                        base_count[0]++; base_count[1]++; base_count[2]++; base_count[3]++;
                        node->feature.push_back((base_count[0]*base_count[3]*base_count[1]*base_count[2])/read_len);
                    }
                } break;
                case 2: break;
                case 3: break;
            }
            j = (j + 1) % 4;
        }
        ifs.close();
        node->name = files_name_list[i];
        node->reads_num = reads_num;

        #pragma omp critical
        {
            total_reads_num = total_reads_num + reads_num;
            files_node_list.push_back(node);
        }

    }
    /*for(int i=0; i<read_length_list.size(); i++){
        if(read_length_list[i]!=read_length_list[0]) {
            cout << "  please fix reads to same length, please!" << endl;
            cout << "  wrong file as follow:" << endl << "  " << files_name_list[i] << endl;
            return 0;
            }
    } */
    read_length = read_length_list[0];
    return 1;

}
void get_sim_node_list(){
    cout << "  running get_sim_node_list()......" << endl;
    cout << "  files_name_list.size()......." << files_name_list.size() << endl;
    #pragma omp parallel for num_threads(thread_num)
    for(int i=0; i<files_name_list.size(); i++){
        for(int j=0; j<i; j++){
            if(files_node_list[i]->name != files_node_list[j]->name){
                sim_node *new_sim_node = new sim_node();
                new_sim_node->file_name_A = files_node_list[i]->name;
                new_sim_node->file_name_B = files_node_list[j]->name;
                new_sim_node->reads_num_A = files_node_list[i]->reads_num;
                new_sim_node->reads_num_B = files_node_list[j]->reads_num;
                new_sim_node->sim = DiceIndex(files_node_list[i]->feature, files_node_list[j]->feature);
                #pragma omp critical
                {
                    sim_node_list.push_back(new_sim_node);
                    //cout  << i << " : " << j << " -----> " << new_sim_node->sim << endl;
                }

            }
        }
    }
}


float DiceIndex(vector<int>nums1, vector<int>nums2){
    float A = nums1.size() + nums2.size();
    float alpha = 1/(1 - abs(int(nums1.size()-nums2.size()))/A);
    set<int>s1(nums1.begin(),nums1.end());
    nums1.resize(0);
    for(int i=0;i<nums2.size();i++){
        auto it=s1.find(nums2[i]);
        if(it!=s1.end()){
            nums1.push_back(nums2[i]);
            s1.erase(nums2[i]);
        }
    }
    return alpha*(2 * nums1.size())/A;
}

int descending_reorder(vector<sim_node*> &nums,int begin, int end){
    //cout << begin << " --> " << end << endl;
    if(begin >= end) return 0;
    //cout << begin << " --> "<< end;
    sim_node *key = nums[begin];

    int i=begin;
    int j=end;
    while(i<j){
        while(i<j && nums[j]->sim <= key->sim) j--;
        while(i<j && nums[i]->sim >= key->sim) i++;
        if(i<j){
            sim_node *sn = nums[i];
            nums[i] = nums[j];
            nums[j] = sn;
        }
    }
    nums[begin] = nums[i];
    nums[i] = key;
    descending_reorder(nums, begin, i-1);
    descending_reorder(nums, i+1, end);
    return 1;
}


int get_Xinfo(){
    ifstream ifs;
    string name = input_files_dir + X_path;
    ifs.open(name,std::ios::in);
    string nums; string peak_mem; string Y_size_get;
    getline(ifs, nums); getline(ifs, peak_mem); getline(ifs, Y_size_get);
    ifs.close();
    test_reads_num = stoi(nums.c_str());
    Y_cpm = abs(stoi(peak_mem.c_str())) + 1;
    Y_size = stof(Y_size_get.c_str());
    //cout << nums << "  " << peak_mem << endl;
    //cout << "  Y_cpm : " << Y_cpm << endl;
    //cout << "  X_size : " << test_reads_num << endl;
    return 0;


}