#WYMAGANIA
# biopython
# ht-seq

EXPNAME="new_refseq"


INDIR=/home/julia/Wyniki_sekwencjonowania
INDIR="/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed"
export INDIR

INFILES1=`ls -m $INDIR/*depl_*1.fq.gz | sort `
INFILES1=`echo $INFILES1 | tr -d ' ' `
INFILES2=`ls -m $INDIR/*depl_*2.fq.gz | sort `
INFILES2=`echo $INFILES2 | tr -d ' ' `
echo $INFILES1 $INFILES2

OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
mkdir -p $OUTDIR
LOG=$OUTDIR/$NAME.log

GENOMES_FILE=/home/julia/mikrobiomy_results/new_genomes.fasta

### prepare reference
#echo '' > $GENOMES_FILE
#for file in /mnt/chr7/data/julia/new_clark_bacteria/Bacteria/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'


### map with bowtie2
BOWTIEDIR=/home/julia/lib/bowtie2-2.2.9


INDEXFILE=$OUTDIR/bowtie2_index
LOGFILE=$OUTDIR/bowtie2_sensitive.log
#$BOWTIEDIR/bowtie2-build --threads 8 $GENOMES_FILE $INDEXFILE 2>> $LOGFILE >> $LOGFILE
#echo "index build"


for file in $INDIR/*depl_*1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    probe=`basename $FILENAME`
    OUTNAME=$OUTDIR/${probe}_bowtie

    echo $probe 
    SAMFILE=${OUTNAME}.sam
    #####$BOWTIEDIR/bowtie2 --fast --threads 8 -x $INDEXFILE -1 ${FILENAME}_1.fq.gz -2 ${FILENAME}_2.fq.gz -S $SAMFILE 2>> $LOGFILE
    $BOWTIEDIR/bowtie2 --threads 16 --very-sensitive -N 1 -x $INDEXFILE -1 ${FILENAME}_1.fq.gz -2 ${FILENAME}_2.fq.gz -S $SAMFILE 2>> $LOGFILE 

    #samtools view -b ${SAMFILE} > ${OUTNAME}.bam 
    #samtools sort -@ 2 ${OUTNAME}.bam -o ${OUTNAME}_sorted
    #samtools index ${OUTNAME}_sorted
done







