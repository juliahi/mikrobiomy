#WYMAGANIA
# biopython
# ht-seq

EXPNAME="minimap"

#INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed
INDIR="/home/julia/Wyniki_sekwencjonowania"
export INDIR

OUTDIR=/home/julia/mikrobiomy_results/$EXPNAME
mkdir -p $OUTDIR
LOG=$OUTDIR/$NAME.log


############# old genomes ####################
GENOMES_FILE=/mnt/chr7/data/julia/genomes.fasta
DIR=$OUTDIR/old_genomes

#sh run_minimap.sh $GENOMES_FILE $DIR


############# new genomes ####################

GENOMES_FILE=/mnt/chr7/data/julia/new_genomes.fasta
DIR=$OUTDIR/new_genomes


sh run_minimap.sh $GENOMES_FILE $DIR
