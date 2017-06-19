
K=31
L=200 #lenght of contig


NAME="6685_04-06-2015_depl"
#NAME="all"


OUTDIR=/mnt/chr4/mikrobiomy-2/velvet_${K}
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*`

### assembly
#velvet_1.2.10/velveth $OUTDIR/$NAME $K -fastq -shortPaired -separate $INFILES1  > $OUTDIR/$NAME.txt
#wait
#velvet_1.2.10/velvetg $OUTDIR/$NAME/ -cov_cutoff 5 -ins_length 200 -exp_cov 2  > $OUTDIR/$NAME.txt
#wait
#python after_velvet.py -i $OUTDIR/$NAME/stats.txt -o $OUTDIR/$NAME/hists.pdf -c 1


### index for kallisto
#python select_contigs.py $OUTDIR/$NAME/contigs.fa $OUTDIR/$NAME/long_contigs_$L.fa $L


SUM=$OUTDIR/summary.txt
python after_velvet.py -i $OUTDIR/stats.txt -o $OUTDIR/hists_$K.pdf -c 1 >> $SUM &
Rscript velvet_kmer_distr.R $OUTDIR/stats.txt $OUTDIR/kmer_hists_$K.pdf &






