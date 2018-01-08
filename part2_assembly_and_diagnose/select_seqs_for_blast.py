
import pandas
import random
from Bio import SeqIO
import sys

dirname="/mnt/chr7/data/julia/kallisto_stats/"

from read_kallisto_stats import *


for k in sys.argv[1:]:
    k = int(k) 
    name="6685_04-06-2015_depl"
    
    filename=dirname+name+("_kallisto_%d_out/stats.txt"%k)

    stats = Stats(filename)

    selected = []

    N = 10
    types = []
    zerokmers = stats.get_zerokmers()
    if len(zerokmers) > 0:
    	selected += zerokmers.sample(min(N, len(zerokmers))).index.tolist()
        types += ["zero kmers"]*min(N, len(zerokmers))
    conflicts = stats.get_conflicts()
    if len(conflicts.index) > 0:
        selected += conflicts.sample(min(N, len(conflicts))).index.tolist()
        #selected += data[(data["ti1+2"] == 0)].nlargest(N,"tu1+2").index.tolist()
        types = types + ["conficts"]*min(N, len(conflicts)) 
    
    nonunique = stats.get_nonunique()
    #selected += random.sample(nonunique,10) 
    #selected += data.nlargest(N,"ti1+2").index.tolist()
    selected += nonunique.sample(N).index.tolist()
    types += ["non-unique"]*N
    
    selected += stats.data.nlargest(N, "tu1+2").index.tolist()
    types += ["most transcripts"]*N


    ## write selected reads (first from pair) as fasta file
    with open(dirname+name+"_%d_selected.fasta"%k, "w+") as output:
       datadir = "/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed/"
       records = list(SeqIO.parse(datadir+name+"_1.fq", "fastq"))
       for idx,typ in zip(selected,types): 
           r = records[idx]
           output.write( ">" + r.id + ' '+ str(idx) + ' ' + typ+'\n')
           output.write(str(r.seq) + '\n')

    #with open(dirname+name+'_selected.txt', "a+") as output: 
         #output.write(str(selected)+'\n')
         #names = [ "k","mapped","unmapped (no kmers)","unmapped (conflicts)","nonuniquelly mapped"]
         #values = [ k, len(data[data["ti1+2"] > 0])/n, len(zerokmers)/n, len(conflicts)/n, len(nonunique)/n ]
         #output.write('\t'.join(names)+'\n')
         #output.write('\t'.join([str(v) for v in values])+'\n')
    
     
    
