DIR=/mnt/chr7/data/julia
K=21 #max 31
INDEX_FILE=$DIR/kallisto_index_$K.idx
GENOMES_FILE=$DIR/genomes.fasta
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed



#for file in $DIR/Bacteria/*/*.fna; do
#	cat $file >> $GENOMES_FILE
#done
#echo 'genome_file prepared'


#build index for genome
kallisto index -k $K -i $INDEX_FILE $GENOMES_FILE
echo 'index prepared'

exit
#quantify
FILEN="6683_16-06-2015_"
TYPE=depl
kallisto quant -i $INDEX_FILE -o $DIR/${FILEN}_${TYPE}_kallisto_${K}_out -b 100  --threads=4     $INDIR/${FILEN}_${TYPE}_1.fq.gz $INDIR/${FILEN}_${TYPE}_2.fq.gz
kallisto h5dump -o $DIR/${FILEN}_${TYPE}_kallisto_${K}_out  $DIR/${FILEN}_${TYPE}_kallisto_${K}_out/abundance.h5


