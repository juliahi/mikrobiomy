#iter over fasta sequences
from itertools import groupby
import pandas

def fasta_iter(fasta_file):
    for header, group in groupby(fasta_file, lambda line: line[0] == ">"):
        if header:
            line = group.next()
            ensembl_id = line[1:].strip()
        else:
            sequence = ''.join(line.strip() for line in group)
            yield ensembl_id, sequence

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Get fasta sequences for transcripts in file')
    
    parser.add_argument('-s', '--sequences', type=str, nargs='+', required=True,
                   help='input sequences/pvalues file - one ID per line')
    parser.add_argument('-f', '--fasta', type=str, required=True,
                   help='input FASTA file')
    parser.add_argument('-o', '--output', type=str, required=True,
                   help='output file')
    parser.add_argument('-t', '--type', type=str, choices=['c'], required=True,
                   help='edgeR and Deseq or Wilcoxon selected, or selected by at least 2 methods')
    
    args = parser.parse_args()
    
    names = []
    minpv = None
    longnames = []


    for filename in args.sequences:
        with open(filename, 'r') as f:
            f.readline()
            for line in f:
                ########### warunek
                pvals = line.strip().split(',')
                if len(pvals) < 5: continue
                if minpv == None: minpv = float(pvals[6])
                
                name = pvals[0] + '_log2fold=' + pvals[5] + '_mean1=' + pvals[2] + '_mean2=' + pvals[3]
                
                if args.type == 'c':
                    if (int(pvals[-1]) >= 2) :
                        names.append(pvals[0])
                        longnames.append(name)
                #if args.type == 'e':
                    #if (float(pvals[6]) <= 0.05) or (float(pvals[7]) <= 0.05):# or (float(pvals[6]) <= minpv):
                        #names.append(name)
                #if args.type == 'a':
                    #if (float(pvals[6]) <= 0.05) or (float(pvals[7]) <= 0.05) or (float(pvals[5]) <= minpv):
                        #names.append(name)
                #if args.type == 'w':
                    #if (float(pvals[6]) > 0.05) and (float(pvals[7]) > 0.05) and (float(pvals[5]) <= minpv):
                        #names.append(name)
    #print names
    print len(names)
    d = {}
    for sid, seq in fasta_iter(open(args.fasta)):
        sid = sid.replace(' ', '_')
        if sid in names:
            d[sid] = seq
    
    with open(args.output, 'w+') as outfile: 
        for name, longname in zip(names, longnames):
            outfile.write('>'+longname+'\n')
            outfile.write(d[name]+'\n')
            
             
    
if __name__ == "__main__":
   main()
