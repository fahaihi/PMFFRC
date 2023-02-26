#!/usr/bin/python3
from os.path import getsize
import sys

import argparse
import math

if __name__ == "__main__":
      
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', help='input file path')
    parser.add_argument('-sT', help='Use # as a threshold of letter percentage on raw sequence (default : 1)', default=1)
    args = parser.parse_args()

    in_f_name = args.i    
    checking_threshold = int(args.sT)

    in_f = open(in_f_name, 'r')
    sampling_percent = 1
    lines = in_f.readlines(int(getsize(in_f_name)/100)*sampling_percent)
    in_f.close()
    
    bases_count = dict()
    base_total_count = 0
    
    for line in lines:
        raw_sequence = line.split("\n")[0]
        
        for i in raw_sequence:
            if i not in bases_count:
                bases_count[i]=0
            else:
                bases_count[i] = bases_count[i] + 1

    base_total_count = sum(bases_count.values())
    sort_bases_count = sorted(bases_count.items(), key=lambda x: x[1], reverse=True)
    
    priority_dict = dict()
    priority_bases = list()
    for i in sort_bases_count:
        if((i[1]/(base_total_count+1))*100 > checking_threshold):
            priority_dict[i[0]] = 0
            priority_bases.append(i[0])
        else:
            break


    for raw_sequence in sys.stdin:

        raw_sequence_length = len(raw_sequence)
        
        for i in priority_bases:
            priority_dict[i] = 0
                
        for i in raw_sequence:
            if i in priority_dict:
                priority_dict[i] = priority_dict[i]+1
        
        printing_ten_score = ""
        printing_score = ""
        #################################################################################
        for priority_base in priority_bases:
            score = (99*priority_dict[priority_base]/(raw_sequence_length+1))
            printing_ten_score = printing_ten_score + str(int(score/10))
            printing_score     = printing_score     + str(int(score%10))
        
        #################################################################################

        printing_score = printing_ten_score + printing_score
        print(printing_score)
        
    
