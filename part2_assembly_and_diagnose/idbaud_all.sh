

L=200 #lenght of contig

NAME="all"
EXPNAME="idba_ud"

#OUTDIR=/mnt/chr4/mikrobiomy-2/results/$EXPNAME
OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
INDIR=/home/julia/Wyniki_sekwencjonowania

mkdir -p $OUTDIR

#INFILES1=`echo $INDIR/*depl_*1.fq.gz`
#INFILES2=`echo $INDIR/*depl_*2.fq.gz`
INFILES1=`ls -m $INDIR/*depl_*1.fq.gz | sort `
INFILES1=`echo $INFILES1 | tr -d ' ' `
INFILES2=`ls -m $INDIR/*depl_*2.fq.gz | sort `
INFILES2=`echo $INFILES2 | tr -d ' ' `

echo $INFILES1 $INFILES2
LOG=$OUTDIR/$NAME.log


IDBADIR=/home/julia/lib/idba-1.1.3/bin
### prepare joined fa files
ALLREADS="/mnt/chr7/data/julia/sga/preprocessed.fq"
#$IDBADIR/fq2fa --paired $ALLREADS $OUTDIR/all_reads.fa


### assembly
#$IDBADIR/idba_ud -r $OUTDIR/all_reads.fa -o $OUTDIR/$NAME --num_threads 8      2> $LOG  >>$LOG


### select contigs
#python select_contigs.py $OUTDIR/$NAME/scaffold.fa $OUTDIR/$NAME/long_contigs_$L.fa $L

SUM=$OUTDIR/summary.txt
python get_seqlengths_from_fasta.py $OUTDIR/$NAME/long_contigs_$L.fa $OUTDIR/$NAME/longcontigs_stats.txt
python after_velvet.py -i $OUTDIR/$NAME/longcontigs_stats.txt -o $OUTDIR/$NAME/${EXPNAME}_hists_longcontigs.pdf -c 1 >> $SUM
python summarize_assemblies.py $$OUTDIR/$NAME/longcontigs_stats.txt 1  


wait


