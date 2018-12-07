K2=$1 #kallisto k
EXPNAME=$2
NAME=$3

L=$MINCONTIGLENGTH

OUTDIRBACK=$OUTDIR
OUTDIR=$OUTDIR/$EXPNAME


INFILES1=`echo $INDIR/*depl_?.fq.gz`
### index for kallisto

KALLISTO="/home/julia/kallisto_kod/src/kallisto"
DIR=$OUTDIR/$NAME/kallisto_on_contigs_${L}/${NAME}_${K2}
mkdir -p $DIR
LOGFILE=$DIR/kallisto_${K2}.log
INDEX_FILE=$DIR/kallisto_index_${K2}.idx
GENOMES_FILE=$OUTDIR/$NAME/long_contigs_$L.fa
echo "velvet dir $OUTDIR" >> $LOGFILE


#####build index
if [ ! -f  $INDEX_FILE ]
then
    echo "build index for $K2, $INDEX_FILE, $GENOMES_FILE" >> $LOGFILE
    $KALLISTO index -k ${K2} -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE
    echo "index prepared"
fi

#mapping

TYPE=depl
#quantify
licznik=0

for file in $INDIR/*depl_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K2}_out
    echo $file

    LOGFILE=${OUTNAME}.log
    SAMFILE=${OUTNAME}.sam
    COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam ${file} ${FILENAME}_2.fq.gz "
    $COMMAND1 2>>${LOGFILE} >${SAMFILE} &
    licznik=$((licznik+1))
    if [ $licznik -eq 1 ]; then
        wait
        licznik=0
    fi
    
done
wait


licznik=0
for file in $INDIR/*depl_1.fq.gz; do
	FILENAME=${file%_1.fq.gz}
	OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K2}_out
    	( samtools view -b ${OUTNAME}.sam > ${OUTNAME}_pseudoal.bam && samtools sort -@ 2 ${OUTNAME}_pseudoal.bam -o ${OUTNAME}_pseudoal_sorted.bam && samtools index ${OUTNAME}_pseudoal_sorted.bam && rm ${OUTNAME}_pseudoal.bam ) &
		
	licznik=$((licznik + 1))
    	if [ $licznik -eq 5 ]; then
   		wait
        	licznik=0
    	fi
done
wait

python why_not_mapping.py $DIR $OUTDIR/not_mapping_${EXPNAME}_${NAME} $K2
cp $OUTDIR/not_mapping_${EXPNAME}_${NAME}* $OUTDIRBACK/img/









