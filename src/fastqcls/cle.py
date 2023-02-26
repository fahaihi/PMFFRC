import subprocess
import shlex
import argparse
import glob
import random
import timeit
import os
if __name__ == '__main__':
    path2 = r'/public/home/jd_sunhui/genCompressor/testCode/result/fastqcls-2020.txt'
    file2 = open(path2, 'a+')
    file2.write('****************************\n')
    file2.write('testData:')

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', help='input file path')
    parser.add_argument('-t', help='num of threads', default='8')
    args = parser.parse_args()

    threads = args.t
    input = args.i
    file2.write(input+"\n")
    hash = random.getrandbits(128)
    output = input.split(sep=".")[0] + str(hash)
    command = "mkdir " + output
    subprocess.check_call(command, shell=True)

    byte =os.path.getsize(input)
    file2.write("Source File Size:%dB\n" %byte)
    kb=byte/1024
    if kb >= 1024:
        M = kb / 1024
        if M >= 1024:
            G = M / 1024
            file2.write("Source File Size:%fG\n" % G)
        else:
            file2.write("Source File Size:%fM\n" % M)
    else:
        file2.write("Source File Size:%fK\n" % kb)
    file2.write("Compression Data......\n            Command being timed:python3 cle.py -i")
    file2.write(input+'\n')

    time=0
    #划分时间#
    start_scoring_time = timeit.default_timer()
    command = "split -n r/4 " + input + " " + output + "/"
    subprocess.check_call(command, shell=True)
    end_scoring_time = timeit.default_timer()
    print("%f : split time" % (end_scoring_time - start_scoring_time))
    time += end_scoring_time - start_scoring_time
    #
    command = "cut -f 1 -d ' ' " + output + "/aa > " + output + "/id_front"
    subprocess.check_call(command, shell=True)
    command = "cut -f 2 -d ' ' " + output + "/aa > " + input.split(sep=".")[0] + ".id_back"
    subprocess.check_call(command, shell=True)

    command = "rm -f " + output + ".aa"
    subprocess.check_call(command, shell=True)

    start_scoring_time = timeit.default_timer()
    command = "pypy scoring_seq_dict.py -i " + output + "/ab < " + output + "/ab > " + output + "/score_seq -sT 1"
    subprocess.check_call(command, shell=True)
    end_scoring_time = timeit.default_timer()
    print("%f : scoring time" % (end_scoring_time - start_scoring_time))
    time += end_scoring_time - start_scoring_time

    start_scoring_time = timeit.default_timer()
    command = "paste -d' ' " + output + "/ab " + output + "/id_front " + output + "/score_seq | sort -k3 -k1 --parallel=" + threads + " > " + output + "/sort_seq"
    subprocess.check_call(command, shell=True)
    end_scoring_time = timeit.default_timer()
    print("%f : paste_and_sorting time" % (end_scoring_time - start_scoring_time))
    time += end_scoring_time - start_scoring_time

    command = "rm -f " + output + "/ab"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + output + "/score_seq"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + output + "/id_front"
    subprocess.check_call(command, shell=True)

    command = "cut -f1 -d' ' " + output + "/sort_seq > " + input.split(sep=".")[0] + ".sorted_seq"
    subprocess.check_call(command, shell=True)
    command = "cut -f2 -d' ' " + output + "/sort_seq > " + input.split(sep=".")[0] + ".sorted_seq_id"
    subprocess.check_call(command, shell=True)

    command = "mv " + output + "/ac " + input.split(sep=".")[0] + ".third_line"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + output + "/ac "
    subprocess.check_call(command, shell=True)

    command = "mv " + output + "/ad " + input.split(sep=".")[0] + ".quality"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + output + "/ad "
    subprocess.check_call(command, shell=True)

    command = "rm -rf " + output
    subprocess.check_call(command, shell=True)

    command = "rm -f " + input.split(sep=".")[0] + ".cle"
    subprocess.check_call(command, shell=True)

    start_scoring_time = timeit.default_timer()
    command = "zpaq -method 5 a " + input.split(sep=".")[0] + ".cle " + input.split(sep=".")[0] + ".sorted_seq " + \
              input.split(sep=".")[0] + ".sorted_seq_id " + input.split(sep=".")[0] + ".id_back " + \
              input.split(sep=".")[0] + ".third_line " + input.split(sep=".")[0] + ".quality -threads " + threads
    subprocess.check_call(command, shell=True)
    end_scoring_time = timeit.default_timer()
    print("%f : zpaq time" % (end_scoring_time - start_scoring_time))
    time += end_scoring_time - start_scoring_time

    # command = "zpaq -method 5 a " + input.split(sep=".")[0] + ".zq_seq " + input.split(sep=".")[0] + ".sorted_seq -threads"+ threads
    # subprocess.check_call(command, shell=True)
    # command = "zpaq -method 5 a " + input.split(sep=".")[0] + ".zq_quality " + input.split(sep=".")[0] + ".quality -threads" + threads
    # subprocess.check_call(command, shell=True)
    # command = "zpaq -method 5 a " + input.split(sep=".")[0] + ".zq_head " + input.split(sep=".")[0] + ".id_back " + \
    #           input.split(sep=".")[0] + ".third_line  -threads" + threads
    # subprocess.check_call(command, shell=True)
    #
    #
    # #分别计算
    # size = os.path.getsize(input.split(sep=".")[0] + ".zq_seq")
    # size1 = os.path.getsize(input.split(sep=".")[0] + ".sorted_seq")
    # print("seq_compress:%f " % (size1/size))
    # file2.write("Compression seq Size: %dB\n" % size)
    # file2.write("seq_compress: %f\n" % (size1/size))
    #
    # size = os.path.getsize(input.split(sep=".")[0] + ".zq_quality")
    # size1 = os.path.getsize(input.split(sep=".")[0] + ".quality")
    # print("quality_compress:%f" % (size1 / size))
    # file2.write("Compression quality Size: %dB\n" % size)
    # file2.write("quality_compress: %f\n" % (size1 / size))
    #
    # size = os.path.getsize(input.split(sep=".")[0] + ".zq_head")
    # size1 = os.path.getsize(input.split(sep=".")[0] + ".id_back") + os.path.getsize(input.split(sep=".")[0] + ".third_line")
    # print("head_compress:%f " % (size1 / size))
    # file2.write("Compression head Size: %dB\n" % size)
    # file2.write("head_compress: %f\n" % (size1 / size))

    size = os.path.getsize(input.split(sep=".")[0] + ".cle")
    size1 = os.path.getsize(input)
    print("total_compress:%f" % (size1/size))
    file2.write("Compression File Size: %dB\n" % size)
    kb = size / 1024
    if kb >= 1024:
        M = kb / 1024
        if M >= 1024:
            G = M / 1024
            file2.write("Compression File Size:%fG\n" % G)
        else:
            file2.write("Compression File Size:%fM\n" % M)
    else:
        file2.write("Compression File Size:%fK\n" % kb)
    file2.write("file_compress: %f\n" % (size1 / size))

    command = "rm -f " + input.split(sep=".")[0] + ".quality"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + input.split(sep=".")[0] + ".third_line"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + input.split(sep=".")[0] + ".id_back"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + input.split(sep=".")[0] + ".sorted_seq"
    subprocess.check_call(command, shell=True)
    command = "rm -f " + input.split(sep=".")[0] + ".sorted_seq_id"
    subprocess.check_call(command, shell=True)
    # command = "rm -f " + input.split(sep=".")[0] + ".zq_seq"
    # subprocess.check_call(command, shell=True)
    # command = "rm -f " + input.split(sep=".")[0] + ".zq_quality"
    # subprocess.check_call(command, shell=True)
    # command = "rm -f " + input.split(sep=".")[0] + ".zq_head"
    # subprocess.check_call(command, shell=True)


