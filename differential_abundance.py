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


def get_accession(gid):
        filename = result_dir + '/genbank/' + gid + '.txt'
        handle = open(filename)
        record = SeqIO.read(handle, "genbank")
        return record.annotations['accessions'][0]


def is_plasmid(gid):
        filename = result_dir + '/genbank/' + gid + '.txt'
        handle = open(filename)
        
        defin = SeqIO.read(handle, "genbank").description 
        if 'plasmid' in defin: return True
        if 'complete genome' in defin: return False
        if 'chromosome' in defin: return False
        #print defin
        return False






def make_table(dirs, cuttype):
    gis = []
    names = []
    table = pandas.DataFrame()

    for directory in dirs:
        gis.append([])
        
        tmp = pandas.read_table(directory+'/abundance.tsv', header=0)
        #table['names'] = tmp["target_id"]
        table['names'] = map(lambda x: x.strip().split('|')[1].split('.')[0], tmp["target_id"])
        #table['names'] = map(lambda x: get_name(x.strip().split('|')[1]), tmp["target_id"])
        table[directory.split('/')[-1]] = tmp[cuttype]

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

def count_diff(table, pos_id, neg_id, dirs, ttest, name, output, taxonomies):


    def test(full_row, pos_id, neg_id, ttest):
        row = list(full_row)[1:]
        l1 = [row[x] for x in pos_id]
        l2 = [row[x] for x in neg_id]
        fc = numpy.mean(l1) / numpy.mean(l2)
        if ttest == "rel":
            return (fc, stats.ttest_rel(l1,l2).pvalue, numpy.mean(l1), numpy.mean(l2))
        elif ttest == "ind":
            return (fc, stats.ttest_ind(l1, l2).pvalue, numpy.mean(l1), numpy.mean(l2))
    

    fc_pvals = list(table.apply(test, axis=1, args=(pos_id, neg_id, ttest)))
    pvals = [x[1] for x in list(fc_pvals)]
    #print "min=", min(pvals), "5%=", numpy.nanpercentile(pvals, 5), "25%=", numpy.nanpercentile(pvals, 25), 
    #print "median:", numpy.nanmedian(pvals), "75%=", numpy.nanpercentile(pvals, 75), "95%=", numpy.nanpercentile(pvals, 95), "max=", max(pvals)
    
    print "pval <= 0.05: ", sum([x <= 0.05 for x in pvals]), "out of:", len(pvals)
    
            
    n = len(pvals)
    
    important =  [[list(table['names'])[i], fc_pvals[i][0], x] for i, x in enumerate(pvals) if x*n <= 0.5 ]
    with open(result_dir+'/'+name+'/selected_gis_'+name+ '.txt') as f:
        selected = map(lambda x: x.strip(), f.readlines())

    print "pval-adj <= 0.05: ", sum([x*n <= 0.05 for x in pvals])
    print selected
    for entry in important:
        print entry, get_accession(entry[0]), taxonomies[entry[0]][0], ", in selected=", get_accession(entry[0]) in selected
    
    
    with open(output, "w") as f:
        
        f.write('GI\tname\ttaxonomy\tmean1\tmean2\tfoldChange\tp-value\tp-adj\n')
        pval_names = zip(list(table['names']), list(fc_pvals))
        for name, pval in sorted(pval_names, key=lambda x: float('inf') if math.isnan(x[1][1]) else x[1][1]):
            species, tax = taxonomies[name]
            f.write("%s\t%s\t%s\t%f\t%f\t%f\t%f\t%f\n"%(name, species, tax, pval[2], pval[3], pval[0], pval[1], min(pval[1]*n, 1)))
            if get_accession(name) in selected:
                print name, taxonomies[name]
    return pvals




def main():
    parser = argparse.ArgumentParser(description='Count t-test on kallisto results')

    parser.add_argument('-c', '--cutoff', type=float, required=True,
                   help='cutoff')    
    parser.add_argument('-n', '--number', type=int, required=True,
                   help='number of samples that can miss the cutoff')
    parser.add_argument('-t', '--type', choices=["est_counts", "tpm"], required=True,
                   help='which parameter to take as output')
    parser.add_argument('-k', '--k', type=int, required=True,
                   help='k parameter of kallisto index')
    
    
    args = parser.parse_args()
    cutoff = args.cutoff
    cuttype = args.type
    number = args.number #number of possible probes not fulfilling cuttype >= cutoff -> suggested 0

    k=args.k
    
    name='%s%d_%d_%d'%(cuttype, k, cutoff, number)
    output_dir=result_dir +'/'+name
    dirs = [result_dir+'/'+x for x in os.listdir(result_dir) if os.path.isdir(result_dir+'/'+x) and x.endswith('%d_out'%k)]
    dirs.sort()
    table = make_table(dirs, cuttype )
    
    taxonomies = load_tax()
    
    
    table['species'] = table.apply(lambda x: taxonomies[list(x)[0]][0], axis=1)
    table['taxonomy'] = table.apply(lambda x: taxonomies[list(x)[0]][1], axis=1)
    
    names = list(table['names'])
    table['is_plasmid'] = [ is_plasmid(gid) for gid in names]
    #remove plasmids ?
    table = table[table.is_plasmid == False]
    
    
    table.to_csv(result_dir+("/kallisto%d_%s.tsv"%(args.k, cuttype)), sep='\t', index=False, float_format='%e')
    
    
    
    #normalize by sum(est_counts)
    #print "column sums:", table.sum()
    table.iloc[:, 1:-3] = table.iloc[:, 1:-3].apply(lambda x: x*1000000 / x.sum())
    
    
    count_diff(table, [1,3], [0,2,4], dirs, "ind", name, output_dir+ "/differential_abundance_wt4_wt16_ind.tsv", taxonomies)
    count_diff(table, [1,3], [2,4], dirs, "rel", name, output_dir+ "/differential_abundance_wt4_wt16_rel.tsv", taxonomies)
    count_diff(table, [5,7], [6,8], dirs, "rel", name, output_dir+ "/differential_abundance_tri4_tri16_rel.tsv", taxonomies)
    count_diff(table, [1,3,5,7], [2,4,6,8], dirs, "rel", name, output_dir+ "/differential_abundance_wt_tri_rel.tsv", taxonomies)
    count_diff(table, [1,3], [5,7], dirs, "rel", name, output_dir+ "/differential_abundance_wt4_tri4_rel.tsv", taxonomies)
    count_diff(table, [2,4], [6,8], dirs, "rel", name, output_dir+ "/differential_abundance_wt16_tri16_rel.tsv", taxonomies)
    
main()
