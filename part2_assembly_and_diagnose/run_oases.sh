
K1=$1
K2=$2
NAME=$3

PATH=$PATH:/home/julia


OASESOUTDIR=$OUTDIR/oases_${K1}_$K2/$NAME

mkdir -p $OASESOUTDIR
LOG=$OASESOUTDIR/logging.txt

##### run velveth
#INFILES1=`echo $INDIR/*depl_?.fq.gz`
#~/velvet_1.2.10/velveth $OUTDIR/${NAME}_$K1 $K1 -fastq -shortPaired -separate $INFILES1  >> $LOG
#~/velvet_1.2.10/velveth $OUTDIR/${NAME}_$K2 $K2 -fastq -shortPaired -separate $INFILES1  >> $LOG
##### or link

mkdir -p $OASESOUTDIR/${NAME}_$K1
mkdir -p $OASESOUTDIR/${NAME}_$K2
ln $OUTDIR/velvet_${K1}/${NAME}/Sequences $OASESOUTDIR/${NAME}_$K1/Sequences
ln $OUTDIR/velvet_${K1}/${NAME}/Roadmaps $OASESOUTDIR/${NAME}_$K1/Roadmaps
ln $OUTDIR/velvet_${K2}/${NAME}/Sequences $OASESOUTDIR/${NAME}_$K2/Sequences
ln $OUTDIR/velvet_${K2}/${NAME}/Roadmaps $OASESOUTDIR/${NAME}_$K2/Roadmaps

wait
#( ~/velvet_1.2.10/velvetg $OASESOUTDIR/${NAME}_$K1/ -read_trkg yes >> $LOG && ~/oases/oases $OASESOUTDIR/${NAME}_$K1 >> $LOG ) &
#( ~/velvet_1.2.10/velvetg $OASESOUTDIR/${NAME}_$K2/ -read_trkg yes >> $LOG && ~/oases/oases $OASESOUTDIR/${NAME}_$K2 >> $LOG ) &
wait

echo `date` "merging" >> $LOG
#discard too long reads
MAXLEN=32000
python filter_transcripts.py $OASESOUTDIR/${NAME}_$K1/transcripts.fa $OASESOUTDIR/${NAME}_$K1/transcripts_$MAXLEN.fa $MAXLEN
python filter_transcripts.py $OASESOUTDIR/${NAME}_$K2/transcripts.fa $OASESOUTDIR/${NAME}_$K2/transcripts_$MAXLEN.fa $MAXLEN


K3=25
~/velvet_1.2.10/velveth $OASESOUTDIR/mergedAssembly $K3 -long $OASESOUTDIR/$NAME*/transcripts_$MAXLEN.fa >> $LOG
~/velvet_1.2.10/velvetg $OASESOUTDIR/mergedAssembly -read_trkg yes -conserveLong yes >> $LOG
~/oases/oases $OASESOUTDIR/mergedAssembly -merge yes >> $LOG

################################### 
# Result in mergedAssembly/transcripts.fa


##### summary 

SUM=$OUTDIR/summary.txt

for VERSION in $NAME_$K1 mergedAssembly; do
	SUM=$OASESOUTDIR/summary.txt
	python select_contigs.py $OASESOUTDIR/$VERSION/transcripts.fa $OASESOUTDIR/$VERSION/long_contigs_$L.fa $L
	python get_seqlengths_from_fasta.py $OASESOUTDIR/$VERSION/long_contigs_$L.fa $OASESOUTDIR/$VERSION/longcontigs_stats.txt
	python after_velvet.py -i $OASESOUTDIR/$VERSION/longcontigs_stats.txt -o $OASESOUTDIR/$VERSION/${EXPNAME}_hists_longcontigs.pdf -c 1 >> $SUM
	python summarize_assemblies.py $OASESOUTDIR/$VERSION/longcontigs_stats.txt 1  
	cp $OASESOUTDIR/${VERSION}/${EXPNAME}_hists_longcontigs.pdf $OUTDIR/img/${EXPNAME}_${VERSION}_hists_longcontigs.pdf
done




