

import glob

def compare(dir1, dir2, k, outfile):
    
  #print glob.glob(dir1+'*kallisto_'+str(k)+'_out')
  #print glob.glob(dir2+'*kallisto_'+str(k)+'_out')
  print dir1, dir2
  csv = open(outfile, 'w+')
  csv.write("#%s %s\n"%(dir1, dir2))
  csv.write('\t'.join(["Probe", 'uniquely mapped to 1', 'uniquely mapped to 2', 'mapped to 1', 'mapped to 2',
      'only to 1', 'only to 2', 'to both'])+'\n')
  for filename in sorted(glob.glob(dir1+'*kallisto_'+str(k)+'_out')):
    name = filename.strip('/').split('/')[-1]
    print name
    try:     
        with open(dir2+name+'/stats.txt') as f2:
            #print 'open', dir2
            with open(filename+'/stats.txt') as f1:
                #print 'open2', dir1
                mappings2 = map(lambda(x): int(x.strip().split('\t')[-1]), f2.readlines())
                mappings1 = map(lambda(x): int(x.strip().split('\t')[-1]), f1.readlines())
    except Exception as e:
        print e
        pass
    else:
        print dir1, '\t', dir2
        n=float(len(mappings2))
        print "n=", int(n)
        um1 = len([x for x in mappings1 if x == 1])
        um2 = len([x for x in mappings2 if x == 1])
        m1 = len([x for x in mappings1 if x > 0])
        m2 = len([x for x in mappings2 if x > 0])
        print "uniquely mapped to A", '\t', um1, '\t', um1/n
        print "uniquely mapped to B", '\t', um2, '\t', um2/n
        print "mapped to A", '\t', m1, '\t', m1/n
        print "mapped to B", '\t', m2, '\t', m2/n
    
        only1= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 > 0 and x2 == 0]) 
        only2= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 == 0 and x2 > 0]) 
        both= len([1 for x1, x2 in zip(mappings1, mappings2) if x1 > 0 and x2 > 0]) 


        print "mapped only in A", '\t', only1, '\t', only1/n
        print "mapped only in B", '\t', only2, '\t', only2/n
        print "mapped in both A and B", '\t', both, '\t', both/n, "\n"
        
        csv.write('\t'.join(map(str, [name, um1/n, um2/n, m1/n, m2/n, only1/n, only2/n, both/n]))+'\n')
  csv.close()



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
oases = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa+"/kallisto_on_contigs_200/"
oases2 = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa2+"/kallisto_on_contigs_200/"
oases3 = "/mnt/chr4/mikrobiomy-2/oases_31_21/"+name2+'/'+name_oa3+"/kallisto_on_contigs_200/"


import sys
sys.stdout = open('/mnt/chr4/mikrobiomy-2/compare_all.txt', 'a+')

#for k in [21, 23, 25, 31]:
for k in [21]:
    dir1 = bacteria
    dir2 = velvet + name1 +"_"+str(k)+'/'
    dir3 = oases + name2 + '_' + name_oa +"_"+str(k)+'/'
    dir4 = oases2 + name2 + '_' + name_oa2 +"_"+str(k)+'/'
    dir5 = oases3 + name2 + '_' + name_oa3 +"_"+str(k)+'/'
    csv = '/mnt/chr4/mikrobiomy-2/compare_Bacteria_%s_%d.csv'%(name1, k)
    csv2 = '/mnt/chr4/mikrobiomy-2/compare_%s_%s_%s_%d.csv'%(name1, name2, name_oa, k)
    csv3 = '/mnt/chr4/mikrobiomy-2/compare_%s_%s_%s_%d.csv'%(name1, name2, name_oa2, k)
    csv4 = '/mnt/chr4/mikrobiomy-2/compare_%s_%s_conf_%d.csv'%(name2, name_oa2, k)
    
    print "#kallisto k=", k#, dir1, dir2, dir3
    print 'Bacteria vs Velvet_31'
    #compare(dir1, dir2, k, csv)
    print '----------'
    print 'Velvet_31 vs merged Oases 31_21'
    #compare(dir2, dir3, k, csv2 )
    print '----------'
    print 'Velvet_31 vs Oases 31'
    #compare(dir2, dir4, k, csv3 )
    print '-----------------------------------'
    print 'Oases 31 vs Oases 31_conf'
    compare(dir4, dir5, k, csv4 )
    print '-----------------------------------'

