L=200 #lenght of contig


OUTDIR=/mnt/chr7/data/julia/sga
INDIR=/home/julia/Wyniki_sekwencjonowania

INFILES1=`echo $INDIR/*depl_*fq.gz`
echo $INFILES1

mkdir -p $OUTDIR
READS=$OUTDIR/preprocessed.fq
PREFIX=$OUTDIR/preprocessed

LOG=$OUTDIR/log.txt

######################## run SGA ############################

#sga preprocess --pe-mode=1  -o $READS $INFILES1

CORRECT=1
if [ $CORRECT -eq 1 ]; then
	#sga index -a ropebwt -t 20 --prefix=$PREFIX --no-reverse  $READS  
	echo `date` 'index'
	#sga correct -t 20 -k 21 --prefix=$PREFIX $READS  
	echo `date` 'correct'
	PREFIX=$OUTDIR/preprocessed.ec
	READS=$PREFIX.fa
fi 
#sga index -a ropebwt -t 20 --prefix=$PREFIX $READS  
echo `date` 'index'

FILTER=1
if [ $FILTER -eq 1 ]; then
        #sga filter --no-kmer-check -t 20 ${READS}  
	PREFIX=$PREFIX.filter.pass
        READS=$PREFIX.fa 
	echo `date`  'filter'
fi

OVERLAP=31
#sga overlap -m $OVERLAP -t 20 --prefix=${PREFIX} ${READS} 
echo `date` 'overlap'

#### bo opcja --prefix nie działa
#mv  `basename ${PREFIX}.asqg.gz`  ${PREFIX}_${OVERLAP}.asqg.gz
PREFIX=${PREFIX}_${OVERLAP}

### rozpakowanie grafu nałożeń 
#gunzip -c ${PREFIX}.asqg.gz > ${PREFIX}.asqg  

#sga assemble -o ${PREFIX} ${PREFIX}.asqg.gz
echo `date` 'assemble'

### rozpakowanie "oczyszczonego" grafu nałożeń - assembly wykonuje kilka rzeczy żeby graf uprościć (usuwając potencjalne błędy)
#gunzip -c ${PREFIX}-graph.asqg.gz > ${PREFIX}-graph.asqg


#sga scaffold -o ${PREFIX}.scaf --pe=$READS  ${PREFIX}-contigs.fa
echo `date` 'scaffold'
#sga scaffold2fasta -o ${PREFIX}.scaffolds.fa -a ${PREFIX}-graph.asqg.gz ${PREFIX}.scaf
echo `date` 'scaffold2fasta'


################ after SGA 


STATS=0
CONTIGFILE=$PREFIX-long_contigs_$L.fa
SCAFFOLDFILE=$PREFIX-long_scaffolds_$L.fa
if [ $STATS -eq 1 ]; then
	python select_contigs.py $PREFIX-contigs.fa $CONTIGFILE $L
	python select_contigs.py $PREFIX.scaffolds.fa $SCAFFOLDFILE $L

	SUM=$OUTDIR/summary.txt
	python get_seqlengths_from_fasta.py $CONTIGFILE $PREFIX-longcontigs_stats.txt 

	echo "SGA OVERLAP=$OVERLAP CORRECT=$CORRECT CONTIGS" >> $SUM
	python after_velvet.py -i $PREFIX-longcontigs_stats.txt -o $PREFIX-hists_longcontigs.pdf -c 1 >> $SUM
	python summarize_assemblies.py $PREFIX-longcontigs_stats.txt 1


	python get_seqlengths_from_fasta.py $SCAFFOLDFILE $PREFIX-longscaffolds_stats.txt 
	
	echo "SGA OVERLAP=$OVERLAP CORRECT=$CORRECT SCAFFOLD" >> $SUM
	python after_velvet.py -i $PREFIX-longscaffolds_stats.txt -o $PREFIX-hists_longscaffolds.pdf -c 1 >> $SUM
	python summarize_assemblies.py $PREFIX-longscaffolds_stats.txt 1
fi




MAP=0

K=21
NAME=all
DIR=$OUTDIR/kallisto_on_contigs_$L/${NAME}_$K
INDIR=/home/julia/Wyniki_sekwencjonowania
if [ $MAP -eq 1 ]; then

	####### mapping kallisto

	INDEX_FILE=$DIR/kallisto_index_${K}.idx
	LOGFILE=$DIR/kallisto.log
	KALLISTO="/home/julia/kallisto_kod/src/kallisto"
	mkdir -p $DIR
	if [ ! -f  $INDEX_FILE ]
	then 
		GENOMES_FILE=$CONTIGFILE
		$KALLISTO index -k $K -i $INDEX_FILE $GENOMES_FILE  2>> $LOGFILE
	fi

	TYPE=depl
	#quantify

	licznik=0
	for file in $INDIR/*${TYPE}_1.fq.gz; do
    		FILENAME=${file%_1.fq.gz}
    		OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    		echo $file
    		LOGFILE=${OUTNAME}.log
    		SAMFILE=${OUTNAME}.sam
    		COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} --pseudobam ${file} ${FILENAME}_2.fq.gz "
 	   	$COMMAND1 2>>${LOGFILE} >${SAMFILE} &
    
		licznik=$((licznik + 1))
    		if [ $licznik -eq 5 ]; then
   			wait
        		licznik=0
    		fi
	done
	wait

	licznik=0
	for file in $INDIR/*${TYPE}_1.fq.gz; do
		FILENAME=${file%_1.fq.gz}
		OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    		samtools view -b ${OUTNAME}.sam > ${OUTNAME}_pseudoal.bam ; samtools sort -@ 2 ${OUTNAME}_pseudoal.bam -o ${OUTNAME}_pseudoal_sorted ; samtools index ${OUTNAME}_pseudoal_sorted 
		
		licznik=$((licznik + 1))
    		if [ $licznik -eq 5 ]; then
   			wait
        		licznik=0
    		fi
	done

fi
#python why_not_mapping.py $DIR $OUTDIR/not_mapping_sga${OVERLAP}_$K $K







