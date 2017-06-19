K=$1


DIR=/mnt/chr7/data/julia
#K=31 #max 31
INDEX_FILE=$DIR/kallisto_index_$K.idx
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOGFILE=$DIR/kallisto.log


KALLISTO="~/kallisto_linux-v0.43.0/kallisto"


#for file in $DIR/Bacteria/*/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'

##build index for genome
#$KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE
#echo 'index prepared'
#


TYPE=depl
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_bam
    if [ ! -d "${OUTNAME}" ]; then
        echo $OUTNAME
        
        if [ ! -f "$OUTNAME/pseudoal.sam" ];  then
            COMMAND1="$KALLISTO pseudo -i $INDEX_FILE -o ${OUTNAME}  --pseudobam ${file} ${FILENAME}_2.fq.gz > ${OUTNAME}_pseudoal.sam" 
            echo $COMMAND1
            TIME=$( `time -p sh -c "$COMMAND1"` 2>&1 )
            echo $TIME
            mv ${OUTNAME}_pseudoal.sam $OUTNAME/pseudoal.sam
        fi
        samtools view -Sb $OUTNAME/pseudoal.sam > $OUTNAME/pseudoal.bam
        samtools sort -@ 2 ${OUTNAME}/pseudoal.bam ${OUTNAME}/pseudoal_sorted
        samtools index ${OUTNAME}/pseudoal_sorted.bam 

    fi
done


