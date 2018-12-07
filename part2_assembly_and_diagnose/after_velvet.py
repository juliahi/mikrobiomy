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



def print_stats(colname, col):
    
    print '\t'.join(["name", "length",  "# zeros", "# 1", "median", "95 percentile", "max" ])
    print '\t'.join(map(str, [colname, len(col), col.count(0), col.count(1), np.percentile(col, 50), np.percentile(col, 95), max(col)]))

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
    

def main():
    parser = argparse.ArgumentParser(description='Plot histogram')
    
    parser.add_argument('-i', '--input', type=str, required=True,
                   help='input tsv')
    parser.add_argument('-c', '--columns', type=int, nargs='+', required=True,
                   help='columns')
    parser.add_argument('-o', '--output', type=str, required=True,
                   help='output file')
    
    args = parser.parse_args()
    
    
    data  = pandas.read_csv(args.input, sep='\t', index_col=0)
     
    
    plot_hist(data, args.columns, args.output)


             
    
if __name__ == "__main__":
   main()


