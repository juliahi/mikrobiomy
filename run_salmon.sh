
DIR=/mnt/chr7/data/julia
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed
INDEX=$DIR/salmon_index_fmd
LOGFILE=$DIR/salmon.log


SALMON="/home/julia/Salmon-0.7.2_linux_x86_64/bin/salmon"

##build index for genome
##lightweight-alignment (FMD-based) index instead, one would use the following command:
$SALMON index -t $GENOMES_FILE -i $INDEX --type fmd 2>> $LOGFILE
echo 'index prepared'
#


TYPE=depl
#quantify

for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_salmon_out
    echo $file
    if [ ! -d "${OUTNAME}" ]; then
        echo $OUTNAME
        if [ ! -f "$OUTNAME/pseudoal.sam" ];  then
            COMMAND1="$SALMON quant -i $INDEX -l <LIBTYPE> -1 ${file} -2 ${FILENAME}_2.fq.gz -o $OUTNAME --numThreads 8 --dumpEq --writeMappings=$OUTNAME/pseudoal.sam 2>> $LOGFILE"
            TIME=$( `time -p sh -c "$COMMAND1"` 2>&1 )
            echo $COMMAND1 >> $LOGFILE
            echo $TIME >> $LOGFILE
        fi
        samtools view -Sb $OUTNAME/pseudoal.sam > $OUTNAME/pseudoal.bam
        samtools sort -@ 2 ${OUTNAME}/pseudoal.bam ${OUTNAME}/pseudoal_sorted
        samtools index ${OUTNAME}/pseudoal_sorted.bam 

    fi
done


