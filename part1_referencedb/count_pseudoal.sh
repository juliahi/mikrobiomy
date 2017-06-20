OPTION=$1
VALUE=$2
MISS=$3
K=$4





for file in /mnt/chr7/data/julia/*_depl_kallisto_${K}_bam/pseudoal_sorted.bam;
do
    samtools idxstats $file | cut -f 1,3  > $file.summary
done

selected=/mnt/chr7/data/julia/$OPTION${K}_${VALUE}_${MISS}/selected_gis_$OPTION${K}_${VALUE}_${MISS}.txt


SUMMARY=/mnt/chr7/data/julia/$OPTION${K}_${VALUE}_${MISS}/kallisto_pseudoal_summary.txt

printf 'Probe ID \t Mapped reads \t fraction of all mapped reads \t fraction of all reads\n' > $SUMMARY
for file in /mnt/chr7/data/julia/*_depl_kallisto_${K}_bam/pseudoal_sorted.bam;
do
    #all mapped reads
    echo $file
    s1=`cat $file.summary | cut -f 2 | python -c "import sys; print(sum(int(l) for l in sys.stdin))"`
    #all mapped to selected selected 
    s2=`cat $file.summary | python -c "import sys; selected=[s.strip() for s in open('$selected')]; print(sum(int(l.strip().split('\t')[1]) for l in sys.stdin if '|' in l and l.split('\t')[0].split('|')[3].split('.')[0] in selected))"`

    echo $s1 $s2
    fract=`python -c "print(float($s2)/$s1)"`
    printf "$file \t $s2 \t $fract \n" >> $SUMMARY
done
