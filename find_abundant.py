


import os
import argparse
import sys


from Bio import Entrez
from Bio import SeqIO



#def download_entrez(dirname, gis):

    ##define email for entrez login
    #db           = "nuccore"
    #Entrez.email = "julia.hermanizycka@gmail.com"
    
    #filenames = []
    #if not os.path.exists(dirname):
        #os.makedirs(dirname)
    
    
    #for gid in gis:
        #name = dirname+'/'+gid+'.txt'
        #if not os.path.exists(name):
            
            
            #handle = Entrez.efetch(db=db, rettype="gb", id=gid, retmode = 'text', complexity=0, retmax=10**9)
            #record = handle.read() 
            #out = open(name, 'w')
            #out.write(record)
            #out.close()
            ##sys.stdout.write(handle.read())
        #filenames.append(name)
    #return filenames
        



def get_annots(filename):
        handle = open(filename)
        records = SeqIO.read(handle, "genbank")
        
        for record in [records]:
            for feature in record.features:
                print(feature)




def select_gis(dirs, cutoff, cuttype, number):
    gis = []
    allgis = []
    
    for directory in dirs:
        gis.append([])
        with open(directory+"/abundance.tsv") as f:
            f.readline() #header
            for line in f:
                name, _, _, est_counts, tpm = line.strip().split('\t') 
                if cuttype == "est_counts":
                    value = float(est_counts)
                elif cuttype == "tpm":
                    value = float(tpm)
                
                if value >= cutoff:
                    id = name.split('|')[3].split('.')[0]
                    gis[-1].append(id)
                    allgis.append(id)
        print directory, len(gis[-1])
    
    result = []
    
    for name in list(set(allgis)):
        missing = sum([1 for g in gis if name not in g])
        #print name, missing
        if missing <= number:
            result.append(name)
    return result




def main():
    parser = argparse.ArgumentParser(description='Select abundant genomes')
    
    parser.add_argument('-c', '--cutoff', type=float, required=True,
                   help='cutoff')    
    parser.add_argument('-n', '--number', type=int, required=True,
                   help='number of samples that can miss the cutoff')
    parser.add_argument('-t', '--type', choices=["est_counts", "tpm"], required=True,
                   help='which parameter to take as output')
    
    
    args = parser.parse_args()
    cutoff = args.cutoff
    cuttype = args.type
    number = args.number #number of possible probes not fulfilling cuttype >= cutoff -> suggested 0
    
    k=21
    result_dir='/mnt/chr7/data/julia'
    
    dirs = [result_dir+'/'+x for x in os.listdir(result_dir) if os.path.isdir(result_dir+'/'+x) and x.endswith('%d_out'%k)]
    gis = select_gis(dirs, cutoff, cuttype, number)
    print len(gis), gis
    
    outname = result_dir+("/%s_%d_%d/selected_gis_%s_%d_%d.txt"%(cuttype, cutoff, number, cuttype, cutoff, number))
    with open(outname, 'w') as f:
        for g in gis:
            f.write(g+"\n")
    
    #filenames = download_entrez(result_dir+'/genbank', gis[:2])
    
    #get_annots(outname+'.gb')
    
    
        
main()