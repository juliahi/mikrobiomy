

L=200 #lenght of contig


#NAME="6685_04-06-2015_depl"
NAME="all"


OUTDIR=/mnt/chr4/mikrobiomy-2/megahit_results
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

mkdir -p $OUTDIR

#INFILES1=`echo $INDIR/*depl_*1.fq.gz`
#INFILES2=`echo $INDIR/*depl_*2.fq.gz`
INFILES1=`ls -m $INDIR/*depl_*1.fq.gz | sort `
INFILES1=`echo $INFILES1 | tr -d ' ' `
INFILES2=`ls -m $INDIR/*depl_*2.fq.gz | sort `
INFILES2=`echo $INFILES2 | tr -d ' ' `

echo $INFILES1 $INFILES2
LOG=$OUTDIR/$NAME.log

### assembly
#/home/julia/megahit/megahit -o $OUTDIR/$NAME -1 $INFILES1 -2 $INFILES2 -m 0.5 -t 12 > $OUTDIR/$NAME.txt 2> $LOG  >>$LOG


### select contigs
#python select_contigs.py $OUTDIR/$NAME/final.contigs.fa $OUTDIR/$NAME/long_contigs_$L.fa $L
#python fasta_to_stats.py $OUTDIR/$NAME/final.contigs.fa $OUTDIR/$NAME/stats.txt
python summarize_assemblies.py megahit_results/$NAME/stats.txt 1

wait


