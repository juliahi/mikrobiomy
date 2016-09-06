import glob
import sys


name = sys.argv[1]

dirname="/mnt/chr7/data/julia/Bacteria/"
dirname2 = '/mnt/chr7/data/julia/%s/'%name
inname = dirname2+'selected_gis_%s.gff'%name
outname = dirname2+'selected_gis_%s_nopseudo.gff'%name
id_list = dirname2 + 'selected_gis_%s.txt'%name

d = {}

for line in open(id_list):
     fasta = glob.glob(dirname+'*/'+line.strip()+'.fna')[0]
     if len(glob.glob(dirname+'*/'+line.strip()+'.fna')) > 1:
         print glob.glob(dirname+'*/'+line.strip()+'.fna')
     name = open(fasta).readline()[1:].split('|')
     name = '|'.join(name[:-1]) + '|'
     d[line.strip()] = name 


with open(outname, 'w') as out:
     for line in open(inname):
    	if not 'pseudo' in line:
            if line[0] != '#':
                gid = line.split('\t')[0]
                gid = '_'.join(gid.split('_')[:-1])
                if 'gene' in line:
                     out.write('\t'.join([d[gid]]+line.split('\t')[1:]))
            else:
                out.write(line)

