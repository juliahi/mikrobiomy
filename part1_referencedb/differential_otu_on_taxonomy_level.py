import argparse
import sys
import os
import pandas
import numpy
import math
from scipy import stats

from Bio import Entrez
from Bio import SeqIO



result_dir='/mnt/chr7/data/julia/diff_on_uclust'


def count_diff(table, pos_id, neg_id, dirs, ttest, name, output):

    def test(row, pos_id, neg_id, ttest):
        
        l1 = [row[x] for x in pos_id]
        l2 = [row[x] for x in neg_id]
        
        fc = numpy.mean(l1) / numpy.mean(l2)
        if ttest == "rel":
            return (fc, stats.ttest_rel(l1,l2).pvalue,  numpy.mean(l1), numpy.mean(l2))
        elif ttest == "ind":
            return (fc, stats.ttest_ind(l1, l2).pvalue,  numpy.mean(l1), numpy.mean(l2))
    
    
    pos_id = [sorted(list(table.columns)[1:])[x] for x in pos_id]
    neg_id = [sorted(list(table.columns)[1:])[x] for x in neg_id]
    
    print pos_id, neg_id
    
    fc_pvals = list(table.apply(test, axis=1, args=(pos_id, neg_id, ttest)))
    pvals = [x[1] for x in list(fc_pvals)]
    #print "min=", min(pvals), "5%=", numpy.nanpercentile(pvals, 5), "25%=", numpy.nanpercentile(pvals, 25), 
    #print "median:", numpy.nanmedian(pvals), "75%=", numpy.nanpercentile(pvals, 75), "95%=", numpy.nanpercentile(pvals, 95), "max=", max(pvals)
    
    print "pval <= 0.05: ", sum([x <= 0.05 for x in pvals]), "out of:", len(pvals)
    n = len(pvals)
    print "pval-adj <= 0.05: ", sum([x*n <= 0.05 for x in pvals])
    
    pval_names = zip(list(table['#OTU ID']), fc_pvals)
    with open(output, "w") as f:
        f.write('name\tmean1\tmean2\tfoldChange\tp-value\tp-adj\n')
        for name, pval in sorted(pval_names, key=lambda x: float('inf') if math.isnan(x[1][1]) else x[1][1]):
            m1, m2 = pval[2], pval[3]
            if pval[1]*n < 0.5:
                print name, m1, m2, pval[0], pval[1], min(pval[1]*n, 1)
            f.write("%s\t%f\t%f\t%f\t%f\t%f\n"%(name, m1, m2, pval[0], pval[1], min(pval[1]*n, 1)))

    return pvals




def main():
    parser = argparse.ArgumentParser(description='Select abundant genomes')
    parser.add_argument('-l', '--level', type=int, required=True, 
                   help='taxonomic level') 
    
    
    args = parser.parse_args()
    level = str(args.level)
    
    typ='SILVA' #'GG'
    input_dir=result_dir +'/wyniki_Ilony/analysis_total_uclust_LSU_fwd_'+typ+'/4_taxonomy_summaries/'
    input_name = input_dir+'otu_table_L'+level+'.txt'
    
    output_dir=result_dir
   
    table = pandas.read_table(input_name, header=1)
    print table.columns
    
    numbers = pandas.read_table(result_dir+'/liczba_sekwencji.tsv', names=['probe', 'exptype', 'size'])
    numbers = numbers[numbers.exptype == 'total']
    
    for name in list(table.columns)[1:]:
        def f(row):
            return str(list(row)[0]).startswith(name[:4]+'_'+name[5:7])
        v = int(numbers[numbers.apply(f, axis=1)][[2]].iloc[0])
        table[[name]] = table[[name]]*v
    
    table.to_csv(result_dir+'/counts_level'+level+'_all.tsv', sep='\t', columns=['#OTU ID'] + sorted(list(table.columns)[1:]), index=False, float_format='%e')
    

    #normalize by sum(est_counts)
    print "column sums:", table.sum()
    #table.iloc[:, 1:] = table.iloc[:, 1:].apply(lambda x: x*1000000 / x.sum())
    
    dirs=[]
    name=''
    
    #count_diff(table, [1,3], [0,2,4], dirs, "ind", name, output_dir+ "/differential_level%s_wt4_wt16_ind.tsv"%level)
    #count_diff(table, [1,3], [2,4], dirs, "rel", name, output_dir+ "/differential_level%s_wt4_wt16_rel.tsv"%level)
    #count_diff(table, [5,7], [6,8], dirs, "rel", name, output_dir+ "/differential_level%s_tri4_tri16_rel.tsv"%level)
    #count_diff(table, [1,3,5,7], [2,4,6,8], dirs, "rel", name, output_dir+ "/differential_level%s_wt_tri_rel.tsv"%level)
    #count_diff(table, [1,3], [5,7], dirs, "rel", name, output_dir+ "/differential_level%s_wt4_tri4_rel.tsv"%level)
    #count_diff(table, [2,4], [6,8], dirs, "rel", name, output_dir+ "/differential_level%s_wt16_tri16_rel.tsv"%level)
    
main()
