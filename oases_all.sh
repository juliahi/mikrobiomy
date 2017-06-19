
K1=31
K2=21
L=200 #contig length

NAME="all"

PATH=$PATH:/home/julia/velvet_1.2.10
velveth=/home/julia/velvet_1.2.10/velveth
velvetg=/home/julia/velvet_1.2.10/velvetg
oases=/home/julia/oases/oases

OUTDIR=/mnt/chr4/mikrobiomy-2/oases_${K1}_$K2/${NAME}_covcut
#OUTDIR=/mnt/chr4/mikrobiomy-2/oases_${K1}_$K2/${NAME} #_covcut
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*.gz`

mkdir -p $OUTDIR
LOG=$OUTDIR/logging.txt


##### assembly
echo 'velveth' >> $LOG
#$velveth $OUTDIR/${NAME}_$K1 $K1 -fastq -shortPaired -separate $INFILES1 >> $LOG
#$velveth $OUTDIR/${NAME}_$K2 $K2 -fastq -shortPaired -separate $INFILES1 >> $LOG
wait
echo 'velvetg' >> $LOG
#$velvetg $OUTDIR/${NAME}_$K1/ -cov_cutoff 5 -read_trkg yes >> $LOG &
#$velvetg $OUTDIR/${NAME}_$K2/ -cov_cutoff 5 -read_trkg yes >> $LOG &
wait
#$oases $OUTDIR/${NAME}_$K1 >> $LOG &
#$oases $OUTDIR/${NAME}_$K2 >> $LOG &
wait






####### filter too long transcripts, filter confidence?
MAXLEN=32000
#python filter_transcripts.py $OUTDIR/${NAME}_$K1/transcripts.fa $OUTDIR/${NAME}_$K1/transcripts_$MAXLEN.fa $MAXLEN
#python filter_transcripts_conf.py $OUTDIR/${NAME}_$K1/transcripts.fa $OUTDIR/${NAME}_${K1}_conf/transcripts.fa 1
#python filter_transcripts.py $OUTDIR/${NAME}_$K2/transcripts.fa $OUTDIR/${NAME}_$K2/transcripts_$MAXLEN.fa $MAXLEN


####### merging
echo "merging"
echo "merging" >> $LOG

#$velveth $OUTDIR/mergedAssembly 27 -long $OUTDIR/$NAME*/transcripts_$MAXLEN.fa >> $LOG
#$velvetg $OUTDIR/mergedAssembly -read_trkg yes -conserveLong yes   >> $LOG
#$oases $OUTDIR/mergedAssembly -merge yes >> $LOG


###### summary
SUM=$OUTDIR/summary.txt
#echo "MERGED" >> $SUM
#python after_velvet.py -i $OUTDIR/mergedAssembly/stats.txt -o $OUTDIR/hists_merged.pdf -c 1 >> $SUM
#echo "VELVET K=$K1" >> $SUM
#python after_velvet.py -i $OUTDIR/${NAME}_$K1/stats.txt -o $OUTDIR/hists_$K1.pdf -c 1 >> $SUM
#echo "VELVET K=$K2" >> $SUM
#python after_velvet.py -i $OUTDIR/${NAME}_$K2/stats.txt -o $OUTDIR/hists_$K2.pdf -c 1 >> $SUM

###### summary transcripts
SUM=$OUTDIR/summary.txt
#echo "MERGED" >> $SUM
#python after_velvet.py -i $OUTDIR/mergedAssembly/stats.txt -o $OUTDIR/hists_merged.pdf -c 1 >> $SUM
#echo "id\tlocus\tt\ttranscript\tc\tconfidence\tl\tlgth" >> $OUTDIR/${NAME}_$K1/transcripts_stats.txt
#grep '>' $OUTDIR/${NAME}_${K1}/transcripts.fa | sed "s/_/\t/g" >> $OUTDIR/${NAME}_$K1/transcripts_stats.txt

echo "id\tlocus\tt\ttranscript\tc\tconfidence\tl\tlgth" > $OUTDIR/${NAME}_${K1}_conf/transcripts_stats.txt
grep '>' $OUTDIR/${NAME}_${K1}_conf/transcripts.fa | sed "s/_/\t/g" >> $OUTDIR/${NAME}_${K1}_conf/transcripts_stats.txt

python summarize_assemblies.py $OUTDIR/$NAME_${K1}/transcripts.fa



#echo "OASES K=$K1 TRANSCRIPTS" >> $SUM
#python after_velvet.py -i $OUTDIR/${NAME}_$K1/transcripts_stats.txt -o $OUTDIR/hists_${K1}_transcripts.pdf -c 7 >> $SUM
echo "OASES K=$K1 TRANSCRIPTS CONF=1" >> $SUM
python after_velvet.py -i $OUTDIR/${NAME}_${K1}_conf/transcripts_stats.txt -o $OUTDIR/hists_${K1}_transcripts_conf.pdf -c 7 >> $SUM




