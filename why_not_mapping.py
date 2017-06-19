
import pandas
import random
from Bio import SeqIO
import sys, glob

#dirname="/mnt/chr7/data/julia/kallisto_stats/"
dirname=sys.argv[1]
outname=sys.argv[2]
kvals=sys.argv[3:]

names=['kmers1', 'kmers2', 'contigs1', 'contigs2', 'contigs1+2', 
	'tu1', 'tu2', 'tu1+2', 'ti1', 'ti2', 'ti1+2']

def mean(l): return sum(l)/len(l)





with open(outname+'.tsv', 'w') as outfile:
 with open(outname+'.tex', 'w') as outfile2:
  outfile.write("Filename\tmapped\tuniquelly mapped\tno kmers\tconflicts\tmean number of kmers\n")
  outfile2.write("Filename & mapped (uniquelly) & no kmers & conflicts & mean number of kmers \\\\ \n")
  for k in kvals:
    k = int(k) 
    
    mapowalne=[]
    umapowalne=[]
    niemapowalne_brak=[]
    niemapowalne_konflikt=[]
    kmers=[]

    outfile2.write("\\hline \\\\\n")

    #name="6685_04-06-2015_depl"
    for filename in sorted(glob.glob(dirname+("/*_kallisto_%d_out/stats.txt"%k))):
        
        data = pandas.read_csv(filename, sep='\t', names=names)
        n=float(len(data.index))
        mapped = data[data["ti1+2"] > 0]
        umapped = mapped[mapped["ti1+2"] == 1]
        mapowalne.append(len(mapped.index)/n)
        umapowalne.append(len(umapped.index)/n)
        kmers.append(sum(data["kmers1"] + data["kmers2"])/n)
        unmapped_nokmers = data[data["tu1+2"] == 0]
        unmapped_conflict = data[(data["tu1+2"] > 0) & (data["ti1+2"] == 0)]
        niemapowalne_brak.append(len(unmapped_nokmers.index)/n)
        niemapowalne_konflikt.append(len(unmapped_conflict.index)/n)
        

        
        outfile.write("%s\t%f\t%f\t%f\t%f\t%f\n"%(filename, mapowalne[-1], umapowalne[-1], niemapowalne_brak[-1], niemapowalne_konflikt[-1], kmers[-1]))
        outfile2.write("%s, k=%d & %.1f \\%% (%.1f \\%%) & %.1f \\%% & %.1f \\%% & %.3f  \\\\ \n"%(filename.split('/')[-2][:15].replace('_', '\_'), k, 
            mapowalne[-1]*100, umapowalne[-1]*100, niemapowalne_brak[-1]*100, niemapowalne_konflikt[-1]*100, kmers[-1]))
    if mapowalne != []:
        outfile.write("kmer=%d mean\t%f\t%f\t%f\t%f\t%f\n"%(k, mean(mapowalne), mean(umapowalne), mean(niemapowalne_brak), mean(niemapowalne_konflikt), mean(kmers)))
        outfile2.write("k=%d mean & %.1f \\%% (%.1f \\%%) & %.1f \\%% & %.1f \\%% & %.3f \\\\ \n"%(k, 
            mean(mapowalne)*100, mean(umapowalne)*100, mean(niemapowalne_brak)*100, mean(niemapowalne_konflikt)*100, mean(kmers)))
    


