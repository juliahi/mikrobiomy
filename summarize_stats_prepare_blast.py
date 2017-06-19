
import pandas
import random
from Bio import SeqIO
import sys

dirname="/mnt/chr7/data/julia/kallisto_stats/"


for k in sys.argv[1:]:
    k = int(k) 
    name="6685_04-06-2015_depl"
    filename=dirname+name+("_kallisto_%d_out/stats.txt"%k)

    names=['kmers1', 'kmers2', 'contigs1', 'contigs2', 'contigs1+2', 
	'tu1', 'tu2', 'tu1+2', 'ti1', 'ti2', 'ti1+2']
    data = pandas.read_csv(filename, sep='\t', names=names)

    #unmapped = data[data["ti1+2"] == 0]

    #print k, "unmapped / all", float(len(unmapped.index)) / len(data.index)
    #print k, "out of it unmapped due to conflict", float(sum(unmapped["tu1+2"]>0))/len(unmapped.index)
    n=float(len(data.index))

    
    selected = []

    N = 20
    types = []
    zerokmers = data[(data["kmers1"] == 0) & (data["kmers2"] == 0)].index.tolist()
    if len(zerokmers) > N:
    	selected += random.sample(zerokmers,N) 
        types += ["zero kmers"]*N
    conflicts = data[(data["ti1+2"] == 0) & (data["tu1+2"] > 0)]
    if len(conflicts.index) > 0:
        selected += conflicts.sample(N).index.tolist()
        #selected += data[(data["ti1+2"] == 0)].nlargest(N,"tu1+2").index.tolist()
        types = types + ["conficts"]*min(N, len(conflicts)) 
    
    nonunique = data[(data["ti1+2"] > 1)]
    #selected += random.sample(nonunique,10) 
    #selected += data.nlargest(N,"ti1+2").index.tolist()
    selected += nonunique.sample(N).index.tolist()
    types += ["non-unique"]*N
    
    selected += data.nlargest(N, "tu1+2").index.tolist()
    types += ["most transcripts"]*N


    #with open(dirname+name+"_%d_selected.fasta"%k, "w+") as output:
    #    datadir = "/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed/"
    #    records = list(SeqIO.parse(datadir+name+"_1.fq", "fastq"))
    #    for idx,typ in zip(selected,types): 
    #        #records[idx].name += (' '+typ)
    #        r = records[idx]
    #        output.write( ">" + r.id + ' '+ typ+'\n')
    #        output.write(str(r.seq) + '\n')
    #        #SeqIO.write([records[idx]], output, "fasta")

    with open(dirname+name+'_selected.txt', "a+") as output: 
         output.write(str(selected)+'\n')
         names = [ "k","mapped","unmapped (no kmers)","unmapped (conflicts)","nonuniquelly mapped"]
         values = [ k, len(data[data["ti1+2"] > 0])/n, len(zerokmers)/n, len(conflicts)/n, len(nonunique)/n ]
         output.write('\t'.join(names)+'\n')
         output.write('\t'.join([str(v) for v in values])+'\n')
    
     
    
