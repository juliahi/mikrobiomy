
#INDIR="/home/julia/Wyniki_sekwencjonowania"

GENOMES_FILE=$1
DIR=$2

mkdir -p $DIR
LOG=$DIR/minimap.log

/home/julia/lib/minimap2/minimap2 -x sr -d $DIR/genomes.mmi $GENOMES_FILE 2>> $LOG
echo `date`, "index created"
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_minimap
    echo `date`, $file
    /home/julia/lib/minimap2/minimap2 -a -x sr $DIR/genomes.mmi ${file} ${FILENAME}_2.fq.gz > ${OUTNAME}.sam 2>> $LOG
    samtools view -b -T $GENOMES_FILE ${OUTNAME}.sam > ${OUTNAME}.bam # && rm ${OUTNAME}.sam
    samtools sort -@ 2 ${OUTNAME}.bam -o ${OUTNAME}_sorted.bam #&& rm ${OUTNAME}.bam
    samtools index ${OUTNAME}_sorted.bam
    samtools idxstats ${OUTNAME}_sorted.bam | head
done

python mean_coverages.py $DIR
