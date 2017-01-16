
dir1 = "/mnt/chr7/data/julia/kallisto_stats/"
dir2 = "/mnt/chr4/mikrobiomy-2/kallisto_on_contigs/31_200/"

import glob



for k in [21,25,31]:
  for filename in glob.glob(dir1+'*kallisto_'+str(k)+'_out'):
    name = filename.split('/')[-1]
    print k, '\t', name

    try:     
        with open(filename+'/stats.txt') as f1:
            mappings1 = map(lambda(x): int(x.strip().split('\t')[-1]), f1.readlines())
        with open(dir2+name+'/stats.txt') as f2:
            mappings2 = map(lambda(x): int(x.strip().split('\t')[-1]), f2.readlines())
    except Exception:
        pass
    else:
        n=float(len(mappings2))
        print "n=", int(n)
        m1 = len([x for x in mappings1 if x > 0])
        m2 = len([x for x in mappings2 if x > 0])
        print "mapped to Bacteria", '\t', m1, '\t', m1/n
        print "mapped to contigs", '\t', m2, '\t', m2/n
    
        only1= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 > 0 and x2 == 0]) 
        only2= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 == 0 and x2 > 0]) 
        both= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 > 0 and x2 > 0]) 


        print "mapped only in Bacteria", '\t', only1, '\t', only1/n
        print "mapped only in contigs", '\t', only2, '\t', only2/n
        print "mapped in both", '\t', both, '\t', both/n

