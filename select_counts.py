import pandas
from Bio import SeqIO

direct="/mnt/chr4/mikrobiomy-2/kallisto_on_contigs/31_200/deseq_21/"
data=pandas.read_csv(direct+"counts.tsv", sep='\t')


data["length"] = data["name"].map(lambda x: float(x.split('_')[3]))
data["cov"] = data["name"].map(lambda x: float(x.split('_')[5]))


length_max = data.sort("length", ascending=False)[:5]
length_max["type"] = "max_length"
cov_max = data.sort("cov", ascending=False)[:5]
cov_max["type"] = "max_cov"


#data["sum"] = data.sum(1, numeric_only=True)
data["sum_wt"] = data.apply(lambda x: sum(x[1:5]), axis=1)
data["sum_tri"] = data.apply(lambda x: sum(x[5:]), axis=1)


reads_max_wt = data.sort("sum_wt", ascending=False)[:5]
reads_max_tri = data.sort("sum_tri", ascending=False)[:5]

reads_max_wt["type"] = "max_wt"
reads_max_tri["type"] = "max_tri"


data["diff"] = data.apply(lambda x: x['sum_wt'] - x['sum_tri'], axis=1)

diff = data.sort("diff", ascending=False)[:5]
diff2 = data.sort("diff", ascending=True)[:5]

diff["type"] = "more_wt"
diff2["type"] = "more_tri"

frames = [length_max, cov_max, reads_max_wt, reads_max_tri, diff, diff2 ]
result = pandas.concat(frames)
print result["name"]



result.to_csv(direct+"selected.tsv",sep='\t')

with open(direct+"selected2.fa", 'w+') as fout:
    fasta_sequences = SeqIO.parse('/mnt/chr4/mikrobiomy-2/velvet_31/all/long_contigs_200.fa', 'fasta')
    for seq in fasta_sequences:
        if seq.id in list(result["name"]):
            #seq.description = seq.description + '_' + list(result[result["name"]==seq.id]["type"])[0]
            print seq.id
            SeqIO.write([seq],fout,"fasta")
    
