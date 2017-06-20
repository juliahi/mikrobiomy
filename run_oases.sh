
K1=31
K2=21

NAME="6685_04-06-2015_depl"
PATH=$PATH:/home/julia/velvet_1.2.10


OUTDIR=/mnt/chr4/mikrobiomy-2/oases_${K1}_$K2/$NAME
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

mkdir $OUTDIR
LOG=$OUTDIR/logging.txt

#velvet_1.2.10/velveth $OUTDIR/${NAME}_$K1 $K1 -fastq -shortPaired -separate $INDIR/${NAME}_1.fq.gz $INDIR/${NAME}_2.fq.gz >> $LOG
#velvet_1.2.10/velveth $OUTDIR/${NAME}_$K2 $K2 -fastq -shortPaired -separate $INDIR/${NAME}_1.fq.gz $INDIR/${NAME}_2.fq.gz >> $LOG
wait

#velvet_1.2.10/velvetg $OUTDIR/$NAME/ -cov_cutoff 5 -ins_length 200 -exp_cov 2  > $OUTDIR/$NAME.txt
#velvet_1.2.10/velvetg $OUTDIR/${NAME}_$K1/ -read_trkg yes >> $LOG
#oases/oases $OUTDIR/${NAME}_$K1 >> $LOG
#velvet_1.2.10/velvetg $OUTDIR/${NAME}_$K2/ -read_trkg yes >> $LOG
#oases/oases $OUTDIR/${NAME}_$K2 >> $LOG
wait

echo "merging"
echo "merging" >> $LOG

#velvet_1.2.10/velveth $OUTDIR/mergedAssembly $K2 -long $OUTDIR/$NAME*/transcripts.fa >> $LOG
#velvet_1.2.10/velvetg $OUTDIR/mergedAssembly -read_trkg yes -conserveLong yes >> $LOG
#oases/oases $OUTDIR/mergedAssembly -merge yes >> $LOG


SUM=$OUTDIR/summary.txt
echo "MERGED" >> $SUM
python after_velvet.py -i $OUTDIR/mergedAssembly/stats.txt -o $OUTDIR/hists_merged.pdf -c 1 >> $SUM
echo "VELVET K=$K1" >> $SUM
python after_velvet.py -i $OUTDIR/${NAME}_$K1/stats.txt -o $OUTDIR/hists_$K1.pdf -c 1 >> $SUM
echo "VELVET K=$K2" >> $SUM
python after_velvet.py -i $OUTDIR/${NAME}_$K2/stats.txt -o $OUTDIR/hists_$K2.pdf -c 1 >> $SUM



