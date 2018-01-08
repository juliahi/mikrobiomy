

import glob
import pandas

def summarize(dir1, k):
    print dir1
    result = {}
    for filename in sorted(glob.glob(dir1+'*kallisto_'+str(k)+'_out')):
        name = filename.strip('/').split('/')[-1]
        try:
            with open(filename+'/stats.txt') as f1:
                mappings1 = map(lambda(x): int(x.strip().split('\t')[-1]), f1.readlines())
            n=float(len(mappings1))
            print filename, "n=", int(n)
            #um1 = len([x for x in mappings1 if x == 1])
            #m1 = len([x for x in mappings1 if x > 0])
            um1 = sum(1 for x in mappings1 if x == 1)
            m1 = sum(1 for x in mappings1 if x > 0)
            print "uniquely mapped to A", '\t', um1, '\t', um1/n
            print "mapped to A", '\t', m1, '\t', m1/n
    
            #csv.write(','.join(map(str, [name, um1/n, m1/n]))+'\n')
            result[name]=( um1/n, m1/n)
        except:
            pass
    return result
  #csv.close()



bacteria = "/mnt/chr7/data/julia/kallisto_stats/"

name1="all"
name2="all_covcut"
#name="6685_04-06-2015_depl"
#name="all/all_31"
#name_oa=name+"_31"
name_oa="mergedAssembly"
name_oa2=name1+"_31"
name_oa3=name1+"_31_conf"


velvet = "/mnt/chr4/mikrobiomy-2/velvet_31/"+name1+"/kallisto_on_contigs_200/"
#velvet2 = "/mnt/chr4/mikrobiomy-2/velvet_21/"+name1+"/kallisto_on_contigs_200/"
oases = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name1+'/'+name_oa+"/kallisto_on_contigs_200/"
oases1 = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa+"/kallisto_on_contigs_200/"
oases2 = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa2+"/kallisto_on_contigs_200/"
oases3 = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa3+"/kallisto_on_contigs_200/"
metavelvet = "/mnt/chr4/mikrobiomy-2/metavelvet_31/"+name1+"/kallisto_on_contigs_200/"
metavelvet2 = "/mnt/chr4/mikrobiomy-2/metavelvet_21/"+name1+"/kallisto_on_contigs_200/"
megahit = "/mnt/chr4/mikrobiomy-2/megahit/"+name1+"/kallisto_on_contigs_200/"


import sys
from itertools import chain
sys.stdout = open('/mnt/chr4/mikrobiomy-2/compare_all.txt', 'a+')



def pd(key, d):
    if key in d: return ",{:.3f},{:.3f}".format(d[key][0],d[key][1])
    else: return ",,"

#for k in [21, 23, 25, 31]:
for k in [21,31]:
    dir1 = bacteria
    dir2a = velvet + name1 +"_"+str(k)+'/'
    #dir2b = velvet2 + name1 +"_"+str(k)+'/'
    dir3 = oases + name1 + '_' + name_oa +"_"+str(k)+'/'
    dir3a = oases1 + name2 + '_' + name_oa +"_"+str(k)+'/'

    dir3b = oases2 + name2 + '_' + name_oa2 +"_"+str(k)+'/'
    dir3c = oases3 + name2 + '_' + name_oa3 +"_"+str(k)+'/'
    dir4a = metavelvet + name1 + "_"+str(k)+'/'
    dir4b = metavelvet2 + name1 + "_"+str(k)+'/'
    dir5 = megahit + name1 + "_"+str(k)+'/'

    csv = open('/mnt/chr4/mikrobiomy-2/new_compare2_%s_%d.csv'%(name1, k), 'a')
    
    #csv.write(",CLARK Bacteria,,Velvet 31,,Oases Merged no covcut,,Oases Merged,,Oases k=31,,Oases k=31 confidence=1, Metavelvet 31,,Metavelvet 21,,Megahit\n")
    print "#kallisto k=", k#, dir1, dir2, dir3
    
    rs = [('CLARK Bacteria (unique),(mapped)', summarize(dir1, k)), 
          ('Velvet 31 (unique),(mapped)', summarize(dir2a, k)), #summarize(dir2b, k), 
          ('Oases Merged no covcut,',  summarize(dir3, k)),
          ('Oases Merged 31_21,',  summarize(dir3a, k)), 
          ('Oases k=31,',  summarize(dir3b, k)), 
          ('Oases k=31 confidence=1,',  summarize(dir3c, k)), 
          ('Metavelvet 31,',  summarize(dir4a, k)), 
          ('Metavelvet 21,',  summarize(dir4b, k)),
          ('Megahit,',  summarize(dir5, k))
            ]
    #newrs=[]
    #for d in rs:
    #    if d != {}:
    #        newrs.append(d)

    #rs = newrs
    s='Name'
    for name, r in rs:
        s += ','+name
    csv.write(s+'\n')
    
    for key in sorted(set(chain.from_iterable([r[1].keys() for r in rs]))):
        s = key
        for name, r in rs:
            s += pd(key, r)
        csv.write(s + '\n')

