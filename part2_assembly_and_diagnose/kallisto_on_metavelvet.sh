
#run after oases_all

K1=31
L=200 #contig length


if [ $# -le 2 ]; then
    echo "usage: kallisto_on_metavelvet.sh kallisto_K NAME [subdir]" 
    exit
fi




NAME=$2

#NAME="all"
#NAME="6685_04-06-2015_depl"

K=$1

OUTDIR=/mnt/chr4/mikrobiomy-2/metavelvet_${K1}/$NAME
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOG=$OUTDIR/logging.txt


echo $OUTDIR, kallisto k=$K



####### mapping kallisto

DIR=$OUTDIR/kallisto_on_contigs_$L/${NAME}_$K
INDEX_FILE=$DIR/kallisto_index_${K}.idx
LOGFILE=$DIR/kallisto.log
KALLISTO="/home/julia/kallisto_kod/src/kallisto"

mkdir -p $DIR
if [ ! -f  $INDEX_FILE ]
then 
	python select_contigs.py $OUTDIR/meta-velvetg.contigs.fa $OUTDIR/long_contigs_${L}.fa $L >> /dev/null

	#KALLISTO="/home/julia/kallisto_linux-v0.43.0/kallisto"
	GENOMES_FILE=$OUTDIR/long_contigs_${L}.fa
	echo "metavelvet $OUTDIR" >> $LOGFILE
	$KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE

	echo "index prepared"
fi

TYPE=depl
#quantify

licznik=0
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    echo $file
    ########COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} -b 100 ${file} ${FILENAME}_2.fq.gz 2>>$LOGFILE"
    LOGFILE=${OUTNAME}.log
    SAMFILE=${OUTNAME}.sam
    COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam ${file} ${FILENAME}_2.fq.gz "
    ##############COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5 2>>${LOGFILE}"
    
    #$COMMAND1 2>>${LOGFILE} >${SAMFILE} &
    

    licznik=$((licznik + 1))
    
    if [ $licznik -eq 4 ]; then
        wait
        licznik=0
    fi
    #TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1  )

    #echo $COMMAND1
    #echo $TIME          
done
#fi
wait

TYPE=depl
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    samtools view -b ${OUTNAME}.sam > ${OUTNAME}_pseudoal.bam 

    samtools sort -@ 2 ${OUTNAME}_pseudoal.bam -o ${OUTNAME}_pseudoal_sorted
    samtools index ${OUTNAME}_pseudoal_sorted
done
