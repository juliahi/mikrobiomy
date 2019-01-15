#WYMAGANIA
# biopython
# ht-seq

EXPNAME="new_refseq"


INDIR="/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed"
export INDIR

INFILES1=`ls -m $INDIR/*depl_*1.fq.gz | sort `
INFILES1=`echo $INFILES1 | tr -d ' ' `
INFILES2=`ls -m $INDIR/*depl_*2.fq.gz | sort `
INFILES2=`echo $INFILES2 | tr -d ' ' `
echo $INFILES1 $INFILES2

OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
mkdir -p $OUTDIR
LOG=$OUTDIR/$NAME.log

GENOMES_FILE=/home/julia/mikrobiomy_results/new_genomes.fasta

### prepare reference
#echo '' > $GENOMES_FILE
#for file in /home/julia/mikrobiomy_results/new_clark_bacteria/Bacteria/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'


### about reference
#python analyze_split_fasta.py $GENOMES_FILE 


### map to new database with kallisto k

for K in 21; do
    print $K
    ./run_kallisto_k.sh $K $GENOMES_FILE $OUTDIR
done
python ../part2_assembly_and_diagnose/why_not_mapping.py $OUTDIR/$NAME $OUTDIR/not_mapping_${EXPNAME}_${NAME} 21



