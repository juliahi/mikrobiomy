


import os
import argparse
import sys
from Bio import Entrez
from Bio import SeqIO



def download_entrez(dirname, gis):

    #define email for entrez login
    db           = "nuccore"
    Entrez.email = "julia.hermanizycka@gmail.com"

    
    #handle = Entrez.esearch( db=db,term=" ".join(accs),retmax=retmax )
    #giList = Entrez.read(handle)['IdList']
    
    
    filenames = []
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    
    
    for gid in gis:
        name = dirname+'/'+gid+'.txt'
        if not os.path.exists(name):
            
            
            handle = Entrez.efetch(db=db, rettype="gb", id=gid, retmode = 'text', complexity=3, retmax=10**9)
            record = handle.read() 
            out = open(name, 'w')
            out.write(record)
            out.close()
            #sys.stdout.write(handle.read())
        filenames.append(name)
    return filenames
        



def get_name(filename):
        handle = open(filename)
        record = SeqIO.read(handle, "genbank")
        return (record.annotations['source'], '_'.join(record.annotations['taxonomy']))




def make_table(dirs, cutoff, cuttype, outname):
    gis = []
    allgis = []
    
    for directory in dirs:
        gis.append({})
        with open(directory+"/abundance.tsv") as f:
            f.readline() #header
            for line in f:
                name, _, _, est_counts, tpm = line.strip().split('\t') 
                if cuttype == "est_counts":
                    value = float(est_counts)
                elif cuttype == "tpm":
                    value = float(tpm)
                
                id = name.split('|')[1].split('.')[0]
                gis[-1][id] = value
                if value >= cutoff:
                    allgis.append(id)
        print directory, len(gis[-1])
    
    allgis = list(set(allgis))
    allgis.sort(key=lambda x: sum([g[x] for g in gis if x in g ]), reverse=True)
    
    
    filenames = download_entrez(result_dir+'/genbank', allgis)
    
    
    with open(outname, "w") as f:
        f.write('GI\tname\ttaxonomy')
        for directory in dirs:
            f.write('\t%s'%directory.split('/')[-1])
        f.write('\tid\n')
        
        for i, gid in enumerate(allgis):
            name, taxonomy = get_name(filenames[i])
            f.write('\t'.join([gid, name, taxonomy]))
            for gdict in gis:
                if gid in gdict:
                    f.write('\t%d'%gdict[gid])
                else:
                    f.write('\t ')
            f.write('\n')




def main():
    parser = argparse.ArgumentParser(description='Select abundant genomes')
    
    parser.add_argument('-c', '--cutoff', type=float, required=True,
                   help='cutoff')    
    parser.add_argument('-n', '--number', type=int, required=True,
                   help='number of samples that can miss the cutoff')
    parser.add_argument('-k', '--k', type=int, required=True,
                   help='k parameter of kallisto index')
    parser.add_argument('-t', '--type', choices=["est_counts", "tpm"], required=True,
                   help='which parameter to take as output')
    
    
    args = parser.parse_args()
    cutoff = args.cutoff
    cuttype = args.type
    number = args.number #number of possible probes not fulfilling cuttype >= cutoff -> suggested 0
    
    
    k=args.k
    global result_dir
    result_dir='/mnt/chr7/data/julia'
    
    outname = result_dir+("/kallisto_summary%d_%s_%d.tsv"%(k, cuttype, cutoff))
    dirs = [result_dir+'/'+x for x in os.listdir(result_dir) if os.path.isdir(result_dir+'/'+x) and x.endswith('%d_out'%k)]
    make_table(sorted(dirs), cutoff, cuttype, outname)
    
        
main()
