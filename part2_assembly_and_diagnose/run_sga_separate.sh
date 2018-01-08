L=200 #lenght of contig


OUTDIR=/mnt/chr7/data/julia/sga_sep
INDIR=/home/julia/Wyniki_sekwencjonowania

INFILES1=`echo $INDIR/*depl_*fq.gz`
echo $INFILES1

mkdir -p $OUTDIR

LOG=$OUTDIR/log.txt

######################## run SGA ############################

CORRECT=1
FILTER=1
OVERLAP=31

PREFIX=$OUTDIR

for probe in '6683_16-06-2015' '6685_04-06-2015' '6685_16-06-2015' '6690_04-06-2015' '6690_16-06-2015' '6695_04-06-2015' '6695_16-06-2015' '6704_04-06-2015' '6704_16-06-2015'; do

    PREFIX=$OUTDIR/${probe}.preprocessed
    #sga preprocess --pe-mode=1  -o $PREFIX $INDIR/${probe}_depl_1.fq.gz $INDIR/${probe}_depl_2.fq.gz

    PREF='.preprocessed'
    READS=${PREFIX}.fq
    if [ $CORRECT -eq 1 ]; then
	#sga index -a ropebwt -t 20 --prefix=$PREFIX --no-reverse  $READS  
	echo `date` 'index'
	#sga correct -t 20 -k 21 --prefix=$PREFIX $READS  
        echo `date` 'correct'

	PREFIX=${PREFIX}.ec
	READS=${PREFIX}.fq
        PREF=${PREF}.ec
	#mv `basename $PREFIX`.fa ${READS}
    fi 
    #sga index -a ropebwt -t 20 --prefix=$PREFIX $READS  
    echo `date` 'index'

    if [ $FILTER -eq 1 ]; then
        #sga filter --no-kmer-check -t 20 ${READS}  
	PREFIX=${PREFIX}.filter.pass
        READS=${PREFIX}.fa
	echo `date`  'filter'
        PREF=${PREF}.filter.pass
    fi

done


#for probe in 6685 6690 6695 6704; do
    #sga merge -p $OUTDIR/$probe$PREF $OUTDIR/${probe}_04-06-2015${PREF}.fa $OUTDIR/${probe}_16-06-2015${PREF}.fa
#done
#sga merge -p $OUTDIR/merged1$PREF $OUTDIR/6683_16-06-2015${PREF}.fa $OUTDIR/6685${PREF}.fa
#sga merge -p $OUTDIR/merged2$PREF $OUTDIR/6690${PREF}.fa $OUTDIR/6695${PREF}.fa
#sga merge -p $OUTDIR/merged12$PREF $OUTDIR/merged1${PREF}.fa $OUTDIR/merged2${PREF}.fa
#sga merge -p $OUTDIR/merged$PREF $OUTDIR/merged12${PREF}.fa $OUTDIR/6704${PREF}.fa


PREFIX=$OUTDIR/merged$PREF
READS=${PREFIX}.fa



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


STATS=1
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



####### mapping kallisto
MAP=0
NAME=all
INDIR=/home/julia/Wyniki_sekwencjonowania
K=21
DIR=$OUTDIR/kallisto_on_contigs_$L/${NAME}_$K
if [ $MAP -eq 1 ]; then

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


