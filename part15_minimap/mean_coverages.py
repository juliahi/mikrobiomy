import glob
import sys
import pysam

def check_read(r):
    if r.is_secondary: return False
    if r.is_unmapped: return False
    if r.is_supplementary: return False
    return True


file_pairs = [12066571, 11557403, 1187627, 12888782, 11275417, 7374023, 12136999, 3018723, 8376929]


if __name__ == "__main__":

    workdir = sys.argv[1]
    counts = []
    NPAIRS = sum(counts)
    n = 0
    n2 = 0
    
    for filename in sorted(glob.glob(workdir + "/*_minimap*_sorted.bam")):
        print filename
        with pysam.AlignmentFile(filename, 'rb') as bamfile:
            filereads = 0
            cond_counts = []
            n += sum([x[1] for x in bamfile.get_index_statistics()]) 
            print "mapped & unmapped", bamfile.mapped, bamfile.unmapped, bamfile.mapped+ bamfile.unmapped
            print "chromosomes", len([x[1] for x in bamfile.get_index_statistics()])
            names = [x[0] for x in bamfile.get_intex_statictics()]
            for i, name in enumerate(names):
                c = bamfile.count(name.split()[0], read_callback=check_read)
                filereads += c
                cond_counts.append(c)
            n2 += filereads
            counts.append(filereads)


    print "coverage by bamfile.mapped", float(n)/(NPAIRS*2)
    print "coverage by iterating names (primary alignments only)", float(n2)/(NPAIRS*2)
    
    mean = sum([c*x*2. for c, x in zip(counts, file_pairs)])/len(counts)
    
    print "mean file coverage by iterating names (primary alignments only)", mean
    
    #return counts
        
