#run after velvet_all.sh run_velvet.sh




L=200 #lenght of contig
K2=$1

#NAME="6685_04-06-2015_depl"
NAME="all"


OUTDIR=/mnt/chr4/mikrobiomy-2/megahit_results
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*.gz`
### index for kallisto
#python select_contigs.py $OUTDIR/$NAME/contigs.fa $OUTDIR/$NAME/long_contigs_$L.fa $L

#KALLISTO="/home/julia/kallisto_linux-v0.43.0/kallisto"
KALLISTO="/home/julia/kallisto_kod/src/kallisto"
DIR=$OUTDIR/$NAME/kallisto_on_contigs_$L/${NAME}_${K2}
mkdir -p $DIR
LOGFILE=$DIR/kallisto_${K2}.log
INDEX_FILE=$DIR/kallisto_index_${K2}.idx
GENOMES_FILE=$OUTDIR/$NAME/long_contigs_$L.fa
echo "build index for $K2, $INDEX_FILE, $GENOMES_FILE" >> $LOGFILE
$KALLISTO index -k ${K2} -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE

echo "index prepared"


#mapping

TYPE=depl
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K2}_out
    echo $file
    echo $file >> $LOGFILE
    COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam -b 100 ${file} ${FILENAME}_2.fq.gz 2>>$LOGFILE |  samtools view -Sb - > ${OUTNAME}_pseudoal.bam "
    COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5"
    echo $COMMAND1 >> $LOGFILE
    TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1 )
    echo $TIME >> $LOGFILE
    mv ${OUTNAME}_pseudoal.bam ${OUTNAME}/pseudoal.bam
    samtools sort -@ 2 ${OUTNAME}/pseudoal.bam -o ${OUTNAME}/pseudoal_sorted
    samtools index ${OUTNAME}/pseudoal_sorted
done




