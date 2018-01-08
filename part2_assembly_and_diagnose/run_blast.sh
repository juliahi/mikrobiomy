K=$1
DIR="/mnt/chr7/data/julia/kallisto_stats/"
DIR2="/mnt/chr4/mikrobiomy-2/blast_non_mapping/"

NAME="6685_04-06-2015_depl_"
FASTA="${DIR}${NAME}${K}_selected.fasta"

#tabular output
#ncbi-blast/bin/blastn -db nr -outfmt 7 -out ${DIR2}blast_${NAME}selected_$K.tsv -remote -query $FASTA
#xml output
ncbi-blast/bin/blastn -db nr -outfmt 5 -out "${DIR}blast_${NAME}${K}_selected.xml -remote -query $FASTA
