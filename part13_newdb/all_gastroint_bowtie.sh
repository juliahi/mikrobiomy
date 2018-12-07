#WYMAGANIA
# biopython
# ht-seq

EXPNAME="hmp"

INDIR=/home/julia/Wyniki_sekwencjonowania
export INDIR


INFILES1=`ls -m $INDIR/*depl_*1.fq.gz | sort `
INFILES1=`echo $INFILES1 | tr -d ' ' `
INFILES2=`ls -m $INDIR/*depl_*2.fq.gz | sort `
INFILES2=`echo $INFILES2 | tr -d ' ' `

NAME=hmp_gi_contig

echo $INFILES1 $INFILES2
LOG=$OUTDIR/$NAME.log

OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
mkdir -p $OUTDIR
GENOMES_FILE=/home/julia/mikrobiomy_results/$EXPNAME/$NAME.fa
### prepare reference
#echo '' > $GENOMES_FILE
#for file in /home/julia/mikrobiomy_results/hmp/$NAME/*.fsa; do
#	cat $file | sed -e 's/ /_/g' >> $GENOMES_FILE
#done
#echo 'genome_file prepared'


### map to new database with kallisto k

for K in 21; do
    echo "k=$K"
    ./run_kallisto_k.sh $K $GENOMES_FILE $OUTDIR/$NAME

    python ../part2_assembly_and_diagnose/why_not_mapping.py $OUTDIR/$NAME $OUTDIR/not_mapping_${EXPNAME}_${NAME} $K

done

exit 
## Podsumowanie estymowanej liczby odczytów:
# python kallisto_table.py -c 0 -n 6 -t $OPTION -k $K




### map with bowtie2
BOWTIEDIR=/home/julia/bowtie2-2.2.9


INDEXFILE=$OUTDIR/bowtie2_index
LOGFILE=$OUTDIR/bowtie2_sensitive.log
$BOWTIEDIR/bowtie2-build --threads 8 $GENOMES_FILE $INDEXFILE 2>> $LOGFILE >> $LOGFILE

echo "index build"


#exit 




for file in $INDIR/*1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    probe=`basename $FILENAME`
    OUTNAME=$OUTDIR/${probe}_bowtie

    echo $probe 
    SAMFILE=${OUTNAME}.sam
    #####$BOWTIEDIR/bowtie2 --fast --threads 8 -x $INDEXFILE -1 ${FILENAME}_1.fq.gz -2 ${FILENAME}_2.fq.gz -S $SAMFILE 2>> $LOGFILE
    $BOWTIEDIR/bowtie2 --threads 16 --very-sensitive -N 1 -x $INDEXFILE -1 ${FILENAME}_1.fq.gz -2 ${FILENAME}_2.fq.gz -S $SAMFILE 2>> $LOGFILE 

    #samtools view -b ${SAMFILE} > ${OUTNAME}.bam 
    #samtools sort -@ 2 ${OUTNAME}.bam -o ${OUTNAME}_sorted
    #samtools index ${OUTNAME}_sorted
done













exit









ALLREADS="/mnt/chr7/data/julia/sga/preprocessed.fq"
#$IDBADIR/fq2fa --paired $ALLREADS $OUTDIR/all_reads.fa


### assembly
#$IDBADIR/idba_ud -r $OUTDIR/all_reads.fa -o $OUTDIR/$NAME --num_threads 8      2> $LOG  >>$LOG


### select contigs
#python select_contigs.py $OUTDIR/$NAME/scaffold.fa $OUTDIR/$NAME/long_contigs_$L.fa $L

SUM=$OUTDIR/summary.txt
python get_seqlengths_from_fasta.py $OUTDIR/$NAME/long_contigs_$L.fa $OUTDIR/$NAME/longcontigs_stats.txt
python after_velvet.py -i $OUTDIR/$NAME/longcontigs_stats.txt -o $OUTDIR/$NAME/${EXPNAME}_hists_longcontigs.pdf -c 1 >> $SUM
python summarize_assemblies.py $$OUTDIR/$NAME/longcontigs_stats.txt 1  


wait















################################# WSTĘPNE ANALIZY - kallisto, najczęstsze sekwencje itp ##################################3

OPTION=est_counts
VALUE=5000
MISS=1
K=21

DIR=/mnt/chr7/data/julia

NAME=${OPTION}${K}_${VALUE}_${MISS}


source ~/venv/bin/activate

# Kallisto with pseudoal w probename_out
./run_kallisto_k.sh $K
## old run with pseudoal: w probename_bam
#####./run_kallisto_pseudo.sh $K 

## Podsumowanie estymowanej liczby odczytów, tylko istotne:
python kallisto_table.py -c $VALUE -n $MISS -t $OPTION -k $K
## Pełna tabela
python kallisto_table.py -c 0 -n 6 -t $OPTION -k $K

mkdir -p $DIR/$NAME



# tabelka częstości wszystkich wybranych w oryginalnym mapowaniu kallisto
# na podstawie wygenerowanych bamów
# zapisuje w OPTIONK_VALUE_MISS/kallisto_pseudoal_summary.txt 
sh count_pseudoal.sh $OPTION $VALUE  $MISS  $K


# Różnicowa obecność genomów
# wynik w: differential_abundance_gr1_gr2_type.tsv i kallistoK_OPTION.tsv
python differential_abundance.py  -t $OPTION -c $VALUE -n $MISS -k $K


# różnicowa obecność genomów w danych Ilony z uclust
python differential_otu_on_taxonomy_level.py -l 2
python differential_otu_on_taxonomy_level.py -l 3
python differential_otu_on_taxonomy_level.py -l 4


######################################## Wybór najczęstszych, bowtie  ###################

# # # Wybór genomów z najwiekszą liczbą readów
python find_abundant.py -c $VALUE -n $MISS -t $OPTION -k $K
# ## zapisuje plik txt z wybranymi GI w OPTIONK_VALUE_MISS/selected_gis_OPTIONK_VALUE_MISS.txt

## Dane z Genbank
# wynikowy plik txt tutaj ->  http://www.ncbi.nlm.nih.gov/sites/batchentrez
# dostaje się plik gb
# echo "Run in http://www.ncbi.nlm.nih.gov/sites/batchentrez and download "Genbank full""
# read INPUT 




## Mapowanie Bowtie2:
## robi również sortowanie i index, przygotowuje wcześniej genomy
bash bowtie_map_to_selected.sh $NAME


# # # Adnotacja do gff:
#przygotowuje plik w formacie gff z adnotacją do wybranych genomów
python prepare_gff_from_txt.py $NAME
#filtruje geny, usuwa pseudogeny
python change_gff.py $NAME



# # # # Zliczanie i różnicowa ekspresja w różnych zdefiniowanych grupach próbek
bash htseq_and_deseq.sh $NAME







KALLISTO="/home/julia/kallisto_linux-v0.43.0/kallisto"
 

TYPE=depl
#quantify
for file in $INDIR/*${TYPE}_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$DIR/`basename ${FILENAME}`_kallisto_${K}_out
    echo $file
    if [ ! -f "$OUTNAME/abundance.h5" ];  then
            COMMAND1="$KALLISTO quant -i $INDEX_FILE -o ${OUTNAME} -b 100 --pseudobam --threads=8 ${file} ${FILENAME}_2.fq.gz  > ${OUTNAME}_pseudoal.sam 2>>$LOGFILE"
            COMMAND2="$KALLISTO h5dump -o ${OUTNAME}  ${OUTNAME}/abundance.h5"
            TIME=$( `time -p sh -c "$COMMAND1; $COMMAND2"` 2>&1 )
            echo $COMMAND1
            echo $TIME
            mv ${OUTNAME}_pseudoal.sam $OUTNAME/pseudoal.sam

        samtools view -Sb $OUTNAME/pseudoal.sam > $OUTNAME/pseudoal.bam
        samtools sort -@ 2 ${OUTNAME}/pseudoal.bam ${OUTNAME}/pseudoal_sorted
        samtools index ${OUTNAME}/pseudoal_sorted.bam 

    fi
done











################################# Assemblacja #####################################################3

#....

