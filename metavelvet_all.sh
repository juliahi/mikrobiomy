
K1=21
L=200 #contig length

NAME="all"

PATH=$PATH:/home/julia/velvet_1.2.10
velveth=/home/julia/velvet_1.2.10/velveth
velvetg=/home/julia/velvet_1.2.10/velvetg
metavelvet=/home/julia/MetaVelvet-1.2.02/meta-velvetg

OUTDIR=/mnt/chr4/mikrobiomy-2/metavelvet_${K1}/${NAME}
OUTDIRV=/mnt/chr4/mikrobiomy-2/velvet_${K1}/${NAME}
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*.gz`

mkdir -p $OUTDIR
LOG=$OUTDIR/logging.txt


##### assembly

if [ -f $OUTDIR/Sequences ]; then
    echo 'linking'
    ln $OUTDIRV/Sequences $OUTDIR/Sequences 
    ln $OUTDIRV/Graph2 $OUTDIR/Graph2 
    ln $OUTDIRV/Roadmaps $OUTDIR/Roadmaps
else
    echo 'velveth' >> $LOG
    $velveth $OUTDIRV $K1 -fastq -shortPaired -separate $INFILES1 >> $LOG
fi

wait

if [ -f $OUTDIR/contigs.fa ]; then
    echo 'velvetg' >> $LOG
    $velvetg $OUTDIR -exp_cov auto >> $LOG &
fi
wait

$metavelvet $OUTDIR >> $LOG &
wait






####### filter too long transcripts, filter confidence?
#MAXLEN=32000
#python filter_transcripts.py $OUTDIR/${NAME}_$K1/transcripts.fa $OUTDIR/${NAME}_$K1/transcripts_$MAXLEN.fa $MAXLEN
#python filter_transcripts_conf.py $OUTDIR/${NAME}_$K1/transcripts.fa $OUTDIR/${NAME}_$K1/transcripts_conf.fa 1
#python filter_transcripts.py $OUTDIR/${NAME}_$K2/transcripts.fa $OUTDIR/${NAME}_$K2/transcripts_$MAXLEN.fa $MAXLEN



###### summary
SUM=$OUTDIR/summary.txt
python after_velvet.py -i $OUTDIR/meta-velvetg.Graph2-stats.txt -o $OUTDIR/hists_$K1.pdf -c 1 >> $SUM &
Rscript velvet_kmer_distr.R $OUTDIR/meta-velvetg.Graph2-stats.txt $OUTDIR/kmer_hists_$K1.pdf &
wait




