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
echo $INFILES1 $INFILES2

NAME=hmp_gi_contig
OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
mkdir -p $OUTDIR
LOG=$OUTDIR/$NAME.log

GENOMES_FILE=/home/julia/mikrobiomy_results/$EXPNAME/$NAME.fa
### prepare reference
#echo '' > $GENOMES_FILE
#for file in /home/julia/mikrobiomy_results/hmp/$NAME/*.fsa; do
#	cat $file | sed -e 's/ /_/g' >> $GENOMES_FILE
#done
#echo 'genome_file prepared'


### about reference
#python analyze_split_fasta.py $GENOMES_FILE ${GENOMES_FILE%.fa}_split.fa


### map to new database with kallisto k, to splited sequences
NAME=${NAME}_split
GENOMES_FILE=/home/julia/mikrobiomy_results/$EXPNAME/$NAME.fa
mkdir -p $OUTDIR/$NAME

for K in 21 25 17; do
    echo "k=$K"
    ./run_kallisto_k.sh $K $GENOMES_FILE $OUTDIR/$NAME

    python ../part2_assembly_and_diagnose/why_not_mapping.py $OUTDIR/$NAME $OUTDIR/not_mapping_${EXPNAME}_${NAME} $K

done
