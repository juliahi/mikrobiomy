K=$1 #max 31


DIR=$OUTDIR
OUTDIR=$OUTDIR/kallisto_stats

INDEX_FILE=/mnt/chr7/julia/kallisto_index_$K.idx
GENOMES_FILE=/mnt/chr7/julia/genomes.fasta



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
licznik=0
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$OUTDIR/`basename ${FILENAME}`_kallisto_${K}_out
    echo $file
    if [ ! -f "$OUTNAME/stats.txt" ];  then
            LOGFILE=${OUTNAME}.log
            #( ($KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam -b 100 ${file} ${FILENAME}_2.fq.gz 2>>$LOGFILE |  samtools view -Sb - > ${OUTNAME}_pseudoal.bam) && mv ${OUTNAME}_pseudoal.bam ${OUTNAME}/pseudoal.bam && samtools sort -@ 2 ${OUTNAME}/pseudoal.bam -o ${OUTNAME}/pseudoal_sorted && samtools index ${OUTNAME}/pseudoal_sorted ) &
            ($KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} -b 100 ${file} ${FILENAME}_2.fq.gz 2>>$LOGFILE ) &
            

            licznik=$((licznik + 1))

            if [ $licznik -eq 2 ]; then
                wait
                licznik=0
            fi

    fi

done
wait

