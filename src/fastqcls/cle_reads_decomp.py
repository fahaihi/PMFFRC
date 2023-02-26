
import os
import subprocess
import shlex
import argparse
import glob
import random
import timeit

if __name__ == '__main__':
    path2 = r'/public/home/jd_sunhui/genCompressor/testCode/result/fastqcls-2020.txt'
    file2 = open(path2, 'a+')
    file2.write('De-Compression Data......\n')
    file2.write("            Command being timed:python3 clE_decomp.py -i")

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', help='input file path')
    parser.add_argument('-t', help='num of threads', default='8')
    args = parser.parse_args()

    input = args.i
    threads = args.t
    file2.write(input + '\n')
    hash = random.getrandbits(128)
    output = args.i + str(hash)

    start_time = timeit.default_timer()
    command = "zpaq x " + input + " -threads " + threads
    subprocess.check_call(command, shell=True)

    command = "paste -d ' ' " + input.split(sep=".")[0] + ".sorted_seq_id " + input.split(sep=".")[
        0] + ".sorted_seq1 | sort -V > " + output + ".sort_seq"
    subprocess.check_call(command, shell=True)

    command = "rm -f " + input.split(sep=".")[0] + ".sorted_seq1"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + input.split(sep=".")[0] + ".sorted_seq_id"
    subprocess.check_call(command, shell=True)

    command = "cut -f 2 -d ' ' " + output + ".sort_seq > " + input.split(sep=".")[0] + ".seq"
    subprocess.check_call(command, shell=True)
    command = "cut -f 1 -d ' ' " + output + ".sort_seq > " + input.split(sep=".")[0] + ".id_front"
    subprocess.check_call(command, shell=True)

    command = "rm -f " + output + ".sort_seq"
    subprocess.check_call(command, shell=True)

    command = "rm -f " + input.split(sep=".")[0] + ".id_front"
    subprocess.check_call(command, shell=True)

    end_time = timeit.default_timer()


