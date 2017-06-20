import glob
import sys


name = sys.argv[1]

dirname="/mnt/chr7/data/julia/Bacteria/"
dirname2 = '/mnt/chr7/data/julia/%s/'%name
outname = dirname2+'selected_gis_%s.gff'%name
inname = dirname2+'sequence.txt'
id_list = dirname2 + 'selected_gis_%s.txt'%name



chrom=None
feature = None
with open(outname, 'w') as out:
    out.write("""##gff-version 2
# seqname	source	feature	start	end	score	strand	frame	attributes
""")
    for line in open(inname):
        if line[0] == '>':
            if feature == 'gene':
                 out.write('\t'.join([chrom+'_'+str(nr), '-', 'gene', s, e, '.', strand, '.', ' ; '.join(attributes)]) + '\n')
            chrom=line[1:].strip().split('|')[1].split('.')[0]
            nr = 1
            attributes=[]
            feature = None     
        elif len(line) <= 1: continue
        elif line[0] != '\t':
            if chrom != None and feature == 'gene':
                 out.write('\t'.join([chrom+'_'+str(nr), '-', 'gene', s, e, '.', strand, '.', ' ; '.join(attributes)]) + '\n')
                 nr += 1
            attributes = []
            s, e, feature = line.strip().split('\t')
            if int(s.strip('<>')) < int(e.strip('<>')): strand='+'
            else:
                s, e = e, s
                strand='-'
        else:
            attributes.append(' '.join(line.strip().split('\t')))


    if chrom != None and feature == 'gene':
        out.write('\t'.join([chrom+'_'+str(nr), '-', 'gene', s, e, '.', strand, '.', ' ; '.join(attributes)]) + '\n')
    

