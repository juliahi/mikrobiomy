#iter over fasta sequences
from itertools import groupby

def fasta_iter(fasta_file):
    for header, group in groupby(fasta_file, lambda line: line[0] == ">"):
        if header:
            line = group.next()
            ensembl_id = line[1:].strip()
        else:
            sequence = ''.join(line.strip() for line in group)
            yield ensembl_id, sequence


def filter_file(inputf, outputf, l):
    with open(outputf, 'w+') as f:
        for name, seq in fasta_iter(open(inputf)):
            if len(seq) > l:
                #print name, len(seq)
                f.write('>'+name+'\n')
                i = 0
                while i < len(seq):
                    f.write(seq[i:(i+60)] + '\n')
                    i += 60


import sys

filter_file(sys.argv[1], sys.argv[2], int(sys.argv[3]))


