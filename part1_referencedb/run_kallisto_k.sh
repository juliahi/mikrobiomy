K=$1 #max 31


DIR=/mnt/chr7/data/julia
INDEX_FILE=$DIR/kallisto_index_$K.idx
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOGFILE=$DIR/kallisto.log


KALLISTO="/home/julia/kallisto_linux-v0.43.0/kallisto"
 

#for file in $DIR/Bacteria/*/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'

##build index for genome
if [ ! -f "$INDEX_FILE" ]; then
    echo "build index for $K, $INDEX_FILE, $GENOMES_FILE" >> $LOGFILE
    $KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE
    echo 'index prepared'
fi


TYPE=depl
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    echo $file
    if [ ! -f "$OUTNAME/abundance.h5" ];  then
            COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} -b 100 --pseudobam --threads=8 ${file} ${FILENAME}_2.fq.gz  > ${OUTNAME}_pseudoal.sam 2>>$LOGFILE"
            COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5"
            TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1 )
            echo $COMMAND1
            echo $TIME
            mv ${OUTNAME}_pseudoal.sam $OUTNAME/pseudoal.sam

        samtools view -Sb $OUTNAME/pseudoal.sam > $OUTNAME/pseudoal.bam
        samtools sort -@ 2 ${OUTNAME}/pseudoal.bam ${OUTNAME}/pseudoal_sorted
        samtools index ${OUTNAME}/pseudoal_sorted.bam 

    fi
done


