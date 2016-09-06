import argparse
import sys
import os
import pandas
import numpy
import math
from scipy import stats

from Bio import Entrez
from Bio import SeqIO



result_dir='/mnt/chr7/data/julia'


def get_name(gid):
        filename = result_dir + '/genbank/' + gid + '.txt'
        handle = open(filename)
        record = SeqIO.read(handle, "genbank")
        return (record.annotations['source'], '_'.join(record.annotations['taxonomy']))






def make_table(dirs, cuttype, outname):
    gis = []
    names = []
    table = pandas.DataFrame()

    for directory in dirs:
        gis.append([])
        
        tmp = pandas.read_table(directory+'/abundance.tsv', header=0)
        #table['names'] = tmp["target_id"]
        table['names'] = map(lambda x: x.strip().split('|')[1].split('.')[0], tmp["target_id"])
        #table['names'] = map(lambda x: get_name(x.strip().split('|')[1]), tmp["target_id"])
        table[directory] = tmp[cuttype]

        with open(directory+"/abundance.tsv") as f:
            f.readline() #header
            for line in f:
                name, _, _, est_counts, tpm = line.strip().split('\t') 
                if cuttype == "est_counts":
                    value = float(est_counts)
                elif cuttype == "tpm":
                    value = float(tpm)
                
                id = name.split('|')[1].split('.')[0]
                if id not in names: names.append(id)
                gis[-1] += [value]
    
    return table



def load_tax():
    d = {}
    with open(result_dir+'/kallisto_summary_est_counts_0.tsv') as f:
        for line in f:
            splitted = line.strip().split('\t')
            d[splitted[0]] = splitted[1:3]
    return d

def count_diff(table, pos_id, neg_id, dirs, ttest, output):

    taxonomies = load_tax()

    def test(full_row, pos_id, neg_id, ttest):
        row = list(full_row)[1:]
        l1 = [row[x] for x in pos_id]
        l2 = [row[x] for x in neg_id]
        if ttest == "rel":
            return stats.ttest_rel(l1,l2).pvalue
        elif ttest == "ind":
            return stats.ttest_ind(l1, l2).pvalue
    
    pvals = table.apply(test, axis=1, args=(pos_id, neg_id, ttest))
    print "min=", min(pvals), "5%=", numpy.nanpercentile(pvals, 5), "25%=", numpy.nanpercentile(pvals, 25), 
    print "median:", numpy.nanmedian(pvals), "75%=", numpy.nanpercentile(pvals, 75), "95%=", numpy.nanpercentile(pvals, 95), "max=", max(pvals)
    
    print "pval <= 0.05: ", sum([x <= 0.05 for x in pvals]), "out of:", len(pvals)
    
    n = len(pvals)
    print "pval-adj <= 0.05: ",  [taxonomies[list(table['names'])[i]][0] for i, x in enumerate(pvals) if x*n <= 0.05 ]
    
    
    with open(output, "w") as f:
        
        f.write('GI\tname\ttaxonomy\tp-value\tp-adj\n')
        pval_names = zip(list(table['names']), list(pvals))
        for name, pval in sorted(pval_names, key=lambda x: float('inf') if math.isnan(x[1]) else x[1]):
            species, tax = taxonomies[name]
            f.write("%s\t%s\t%s\t%f\t%f\n"%(name, species, tax, pval, min(pval*n, 1)))
    
    return pvals




def main():
    parser = argparse.ArgumentParser(description='Select abundant genomes')

    parser.add_argument('-c', '--cutoff', type=float, required=True,
                   help='cutoff')    
    parser.add_argument('-n', '--number', type=int, required=True,
                   help='number of samples that can miss the cutoff')
    parser.add_argument('-t', '--type', choices=["est_counts", "tpm"], required=True,
                   help='which parameter to take as output')
    
    
    args = parser.parse_args()
    cutoff = args.cutoff
    cuttype = args.type
    number = args.number #number of possible probes not fulfilling cuttype >= cutoff -> suggested 0

    k=21
    
    output_dir=result_dir +'/%s_%d_%d'%(cuttype, cutoff, number)
    
    dirs = [result_dir+'/'+x for x in os.listdir(result_dir) if os.path.isdir(result_dir+'/'+x) and x.endswith('%d_out'%k)]
    dirs.sort()
    table = make_table(dirs, cuttype, result_dir+("/kallisto_summary.tsv"))
    
    count_diff(table, [1,3], [0,2,4], dirs, "ind", output_dir+"/differential_abundance_wt4_wt16_ind.tsv")
    count_diff(table, [1,3], [2,4], dirs, "rel", output_dir+"/differential_abundance_wt4_wt16_rel.tsv")
    count_diff(table, [5,7], [6,8], dirs, "rel", output_dir+"/differential_abundance_tri4_tri16_rel.tsv")
    count_diff(table, [1,3,5,7], [2,4,6,8], dirs, "rel", output_dir+"/differential_abundance_wt_tri_rel.tsv")
    count_diff(table, [1,3], [5,7], dirs, "rel", output_dir+"/differential_abundance_wt4_tri4_rel.tsv")
    count_diff(table, [2,4], [6,8], dirs, "rel", output_dir+"/differential_abundance_wt16_tri16_rel.tsv")
    
main()
