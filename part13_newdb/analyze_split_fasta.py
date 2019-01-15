


#iter over fasta sequences
import sys
import re


def iter_fasta(filename):
    name = None
    seq = ""
    for line in open(filename):
        if line.startswith(">"):
            if name is not None:
                yield name, seq
            name = line.strip()[1:]
            seq = ""
        else:
            seq += line.strip()

    if name is not None:
        yield name, seq


def main():
    NLEN = 10

    filename = sys.argv[1]
    spliting = False
    if len(sys.argv) > 2:
        spliting = True
        outfilename = sys.argv[2]

    nseqs = 0
    nbases = 0
    nn = 0
    nnseqs = 0

    if spliting:
        output = open(outfilename, 'w')

    for seq_id, sequence in iter_fasta(filename):
        nseqs += 1
        nbases += len(sequence)
        nn += sequence.count('N')

        if 'N' * NLEN in sequence:
            nnseqs += 1

        if spliting:
            if sequence.count('N'*NLEN) == 0:
                output.write(">%s\n%s\n"%(seq_id, sequence))
            else:
                split_seq = re.split("N"*NLEN+"N*", sequence)
                for i, s in enumerate(split_seq):
                    output.write(">%s_part%d\n%s\n" % (seq_id, i, s))
    if spliting:
        output.close()

    print "%d\t%d\t%d\t%d" % (nseqs, nbases, nn, nnseqs)


if __name__ == "__main__":
    main()