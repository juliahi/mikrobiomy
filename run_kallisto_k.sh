K=$1


DIR=/mnt/chr7/data/julia
#K=31 #max 31
INDEX_FILE=$DIR/kallisto_index_$K.idx
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOGFILE=$DIR/kallisto.log

#for file in $DIR/Bacteria/*/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'
#build index for genome
#kallisto index -k $K -i $INDEX_FILE $GENOMES_FILE

echo 'index prepared'

#quantify
FILEN="6683_16-06-2015"
TYPE=depl
COMMAND1="kallisto quant -i $INDEX_FILE -o $DIR/${FILEN}_${TYPE}_kallisto_${K}_out -b 100  --threads=4  $INDIR/${FILEN}_${TYPE}_1.fq.gz $INDIR/${FILEN}_${TYPE}_2.fq.gz"
COMMAND2="kallisto h5dump -o $DIR/${FILEN}_${TYPE}_kallisto_${K}_out  $DIR/${FILEN}_${TYPE}_kallisto_${K}_out/abundance.h5"

time -p sh -c "$COMMAND1; $COMMAND2; echo '$COMMAND1'" >> $LOGFILE


