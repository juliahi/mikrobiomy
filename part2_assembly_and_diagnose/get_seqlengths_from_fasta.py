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


def filter_file(inputf, outputf):
    with open(outputf, 'w+') as f:
        f.write("ID\tlgth\n")
        for name, seq in fasta_iter(open(inputf)):
            f.write("%s\t%d\n"%(name.split()[0], len(seq)))

import sys

filter_file(sys.argv[1], sys.argv[2])
#filter_file(sys.argv[1], sys.argv[2], ))


