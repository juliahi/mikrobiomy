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

def n50(col):
    s = sum(col)
    half = s/2
    for i in sorted(col, reverse=True):
        s -= i
        if s < half:
            return i


def print_stats(colname, col):
    
    print '\t'.join(map(str, [colname, len(col), sum(col), col.count(0), col.count(1), np.percentile(col, 50), np.percentile(col, 95), max(col), n50(col)]))

def plot_hist(data, cols, out):
    
    #plot
    n = len(cols)
    fig = plt.figure()
    chrt=0 
    for column in cols:
        chrt += 1 
        ax = fig.add_subplot( 2,(n+1)/2, chrt)
        ax.set(title=column)    
        colname = data.columns.tolist()[int(column)-1]
            
	col = list(data[colname])
        
        print_stats(colname, col)

        #bound = max(col)
        bound = data[colname].quantile(q=0.99)
        bins = [0] + list( np.linspace(1, bound, 100))
        #bins=100
        dpl = sns.distplot(col, label=colname, rug=False, norm_hist=False, bins=bins, ax=ax, kde_kws={'bw': 3}, kde=False)
        #dpl.set_xlim([0, bound])
        dpl.set(xlabel=colname, ylabel="Counts")
        #break
    
    plt.savefig(out, format='pdf')
    
import sys
def main():
    #parser = argparse.ArgumentParser(description='Plot histogram')
    
    #parser.add_argument('-i', '--input', type=str, required=True,
    #               help='input tsv')
    #parser.add_argument('-c', '--columns', type=int, nargs='+', required=True,
    #               help='columns')
    #parser.add_argument('-o', '--output', type=str, required=True,
    #               help='output file')
    
    #args = parser.parse_args()
   

    indir = "/mnt/chr4/mikrobiomy-2/"
    sys.stdout = open(indir+'assembly_stats.txt', 'a+')
    print '\t'.join(["name", "# contigs", 'sum',  "# zeros", "# 1", "median", "95 percentile", "max", "N50" ])

    if len(sys.argv) == 1:
        lista = [#('velvet_31/all/stats.txt', 31), #('velvet_21/all/stats.txt', 21),
            ('velvet_31_expcovauto/all/stats.txt', 31), 
            ('velvet_21_expcovauto/all/stats.txt', 21), 
            #('oases_31_21/all/all_31/stats.txt', 31),
            #('oases_31_21/all/mergedAssembly/stats.txt', 27), 
            #('oases_31_21/all_covcut/all_31/stats.txt', 31),
            #('oases_31_21/all_covcut/mergedAssembly/stats.txt', 27), ('metavelvet_31/all/stats.txt', 31)
            ]
    elif len(sys.argv) == 3:
        lista =[(sys.argv[1], int(sys.argv[2]))]
    for f,k in lista:
        data = pandas.read_csv(indir+f, sep='\t', index_col=0)
        lengths = data['lgth'].apply(lambda x: x + k - 1 if x > 0 else 0)
        lengths = list(lengths)
        #print f
        # remove zeros
        lengths = [x for x in lengths if x > 0]
        print_stats(f, lengths)
             
    
if __name__ == "__main__":
   main()


