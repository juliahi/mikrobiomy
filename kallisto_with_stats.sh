K=$1 #max 31


DIR=/mnt/chr7/data/julia
OUTDIR=/mnt/chr7/data/julia/kallisto_stats
INDEX_FILE=$DIR/kallisto_index_$K.idx
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOGFILE=$OUTDIR/kallisto_${K}.log


KALLISTO="/home/julia/kallisto_kod/src/kallisto"
 

#for file in $DIR/Bacteria/*/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'

##build index for genome
#echo "build index for $K, $INDEX_FILE, $GENOMES_FILE" >> $LOGFILE
#$KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE
#echo 'index prepared'
#


TYPE=depl
#quantify
for file in $INDIR/6695_*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$OUTDIR/`basename ${FILENAME}`_kallisto_${K}_out
    echo $file
    #if [ ! -f "$OUTNAME/abundance.h5" ];  then
            #COMMAND1="$KALLISTO pseudo -i $INDEX_FILE -o ${OUTNAME}  --pseudobam ${file} ${FILENAME}_2.fq.gz > pseudoal.sam" 

            COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam -b 100 ${file} ${FILENAME}_2.fq.gz 2>>$LOGFILE  |  samtools view -Sb - > ${OUTNAME}_pseudoal.bam   "
            COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5"
            TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1 )
            echo $COMMAND1
            echo $TIME
            mv ${OUTNAME}_pseudoal.bam ${OUTNAME}/pseudoal.bam
            samtools sort -@ 2 ${OUTNAME}/pseudoal.bam -o ${OUTNAME}/pseudoal_sorted
            samtools index ${OUTNAME}/pseudoal_sorted

    #fi
    
done


