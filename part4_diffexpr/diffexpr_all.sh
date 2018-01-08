
EXPNAME=$2
L=200 #lenght of contig
K2=$1
SNAME=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 kallisto_K experiment_name dataset_name  " >&2
        exit 1
fi



DIR=/mnt/chr4/mikrobiomy-2/$EXPNAME/$SNAME/kallisto_on_contigs_${L}/${SNAME}_${K2}


LOGFILE=$DIR/kallisto_${K2}.log

NAME=deseq_$1

#prepare counts
#rm $DIR/$NAME/counts.txt
if [ ! -f $DIR/$NAME/counts.txt ]; then
    file=$DIR/6683_16-06-2015_depl_kallisto_${K2}_out/abundance.tsv
    echo "name" > $DIR/names.txt

    #####cut -f1 $file | tail -n +2  >> ${DIR}/names.txt
    # megahit needs this:
    cat /mnt/chr4/mikrobiomy-2/$EXPNAME/$SNAME/long_contigs_$L.fa | grep '>'    | sed -e 's/ /_/g' | sed -e 's/>//g' >> ${DIR}/names.txt


    for file in $DIR/*_depl_kallisto_${K2}_out/abundance.tsv; do
        echo $file 
        echo $file > ${file%abundance.tsv}est_counts.txt
        cut -f4 $file | tail -n +2 >> ${file%abundance.tsv}est_counts.txt
    done

    mkdir -p $DIR/$NAME
    paste -d '\t' $DIR/names.txt $DIR/*_depl_kallisto_${K2}_out/est_counts.txt > $DIR/$NAME/counts.txt
fi

if [ "$EXPNAME" = "megahit_results" ]; then 
    python filter_counts_before_deseq.py -i $DIR/$NAME/counts.txt -o $DIR/$NAME/counts_filtered.txt  --maxlen 1500 --minlen 500
else 
    #velvet and metavelvet needs adjustment
    K3=${EXPNAME#*'_'}
    #K3=  #remove all after _
    K3=${K3%'_'*}
    echo "adjusting lengths for $EXPNAME by ${K3}" 
    python filter_counts_before_deseq.py -i $DIR/$NAME/counts.txt -o $DIR/$NAME/counts_filtered.txt  --maxlen $((1500-$K3+1)) --minlen $((500-$K3+1))
fi




FA=/mnt/chr4/mikrobiomy-2/$EXPNAME/$SNAME/long_contigs_$L.fa

OPTS="-c $DIR/$NAME/counts_filtered.txt -w -d -l -m -e -o "

Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_all4_all16 1 0 1 0 1 0 1 0 1
python csv_to_tex.py $DIR/$NAME/deseq_all4_all16/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_all4_all16_pvals.tex
python get_selected_fasta.py -s $DIR/$NAME/deseq_all4_all16/pvals.csv -f $FA -o $DIR/$NAME/deseq_all4_all16/all4_all16_selected.fa -t 'c'


Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_wt_tri 0 0 0 0 0 1 1 1 1
python csv_to_tex.py $DIR/$NAME/deseq_wt_tri/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_wt_tri_pvals.tex
python get_selected_fasta.py -s $DIR/$NAME/deseq_wt_tri/pvals.csv -f $FA -o $DIR/$NAME/deseq_wt_tri/wt_tri_selected.fa -t 'c'

Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_wt4_wt16 1 0 1 0 1 - - - -
python csv_to_tex.py $DIR/$NAME/deseq_wt4_wt16/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_wt4_wt16_pvals.tex
python get_selected_fasta.py -s $DIR/$NAME/deseq_wt4_wt16/pvals.csv -f $FA -o $DIR/$NAME/deseq_wt4_wt16/wt4_wt16_selected.fa -t 'c'






exit

Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_tri4_tri16 parametric - - - - 
#Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt4_wt16 parametric 1 0 1 0 1 - - - -- 0 1 0 1
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt_tri parametric 0 0 0 0 0 1 1 1 1
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt4_tri4 parametric - 0 - 0 - 1 - 1 -
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt16_tri16 parametric 0 - 0 - 0 - 1 - 1
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_all4_all16 parametric 1 0 1 0 1 0 1 0 1




Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_tri4_tri16 local - - - - - 0 1 0 1
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt4_tri4 local - 0 - 0 - 1 - 1 -
Rscript run_diffexprs.R $DIR/$NAME/counts_filtered.txt $DIR/$NAME/deseq_wt16_tri16 local 0 - 0 - 0 - 1 - 1


