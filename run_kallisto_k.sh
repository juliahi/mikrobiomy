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
    #FILEN="6683_16-06-2015"
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    #echo $file
    if [ ! -d "${OUTNAME}" ]; then
        echo $OUTNAME
        COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} -b 100  --threads=8  ${file} ${FILENAME}_2.fq.gz"
        COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5"
        TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1 )
        echo $COMMAND1
        echo $TIME
    fi
done


