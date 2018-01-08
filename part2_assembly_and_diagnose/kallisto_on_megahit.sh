#run after velvet_all.sh run_velvet.sh



L=200 #lenght of contig
K=$1

NAME="all"


OUTDIR=/mnt/chr4/mikrobiomy-2/megahit_results/$NAME
INDIR=/home/julia/Wyniki_sekwencjonowania

INFILES1=`echo $INDIR/*depl_*.gz`
### index for kallisto
python select_contigs.py $OUTDIR/final.contigs.fa $OUTDIR/long_contigs_$L.fa $L






DIR=$OUTDIR/kallisto_on_contigs_$L/${NAME}_$K
INDEX_FILE=$DIR/kallisto_index_${K}.idx
LOGFILE=$DIR/kallisto.log
KALLISTO="/home/julia/kallisto_kod/src/kallisto"

mkdir -p $DIR
if [ ! -f  $INDEX_FILE ]
then 
        echo "building index"
	python select_contigs.py $OUTDIR/final.contigs.fa $OUTDIR/long_contigs_$L.fa $L

	#KALLISTO="/home/julia/kallisto_linux-v0.43.0/kallisto"
	GENOMES_FILE=$OUTDIR/long_contigs_${L}.fa
	echo "megahit $OUTDIR" >> $LOGFILE
	$KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE

	echo "index prepared"
fi



#mapping

TYPE=depl

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
    
    $COMMAND1 2>>${LOGFILE} >${SAMFILE} &
    

    licznik=$((licznik + 1))
    
    if [ $licznik -eq 5 ]; then
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



