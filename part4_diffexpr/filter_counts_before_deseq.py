#!/usr/bin/python

import pysam
import argparse

import numpy as np
import pandas

import warnings
warnings.filterwarnings("ignore")

import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
import seaborn as sns

import sys

from math import log





    

def main():
    parser = argparse.ArgumentParser(description='Filter counts before deseq')
    
    parser.add_argument('-i', '--input', type=str, required=True,
                   help='input counts file')
    parser.add_argument('--minlen', type=int, required=False,
                   help='minimal gene length')
    parser.add_argument('--maxlen', type=int, required=False,
                   help='maximal gene length')
    parser.add_argument('-o', '--output', type=str, required=True,
                   help='output counts file')
    
    args = parser.parse_args()

    with open(args.input) as f:
        with open(args.output, 'w+') as outfile:
            outfile.write(f.readline())   #header
            for line in f:
                name = line.split('\t')[0]
                if len(name.split('_')) == 6:   #velvet names
                    length = int(name.split('_')[3])
                    cov = float(name.split('_')[5])
                if len(name.split('_')) == 5:   #megahit names
                    length = int(name.split('_')[4].split('=')[1])
                    cov = float(name.split('_')[3].split('=')[1]) ###?????? 
                

                if (args.minlen is None) or args.minlen <= length:
                    if (args.maxlen is None) or args.maxlen >= length:
                        if cov >= 10:
                            if len([x for x in line.split('\t')[1:] if float(x)>=5]) >= 3:
                                ### good for DESEQ 
                                outfile.write(line)
    
if __name__ == "__main__":
   main()


