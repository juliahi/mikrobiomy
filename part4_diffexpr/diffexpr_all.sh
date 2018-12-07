
EXPNAME=$2
L=200 #lenght of contig
K2=$1
SNAME=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 kallisto_K experiment_name dataset_name  " >&2
        exit 1
fi



DIR=$OUTDIR/$EXPNAME/$SNAME/kallisto_on_contigs_${L}/${SNAME}_${K2}


LOGFILE=$DIR/kallisto_${K2}.log

NAME=deseq_$1

#prepare counts
#rm $DIR/$NAME/counts.txt
if [ ! -f $DIR/$NAME/counts.txt ]; then
    file=$DIR/6683_16-06-2015_depl_kallisto_${K2}_out/abundance.tsv
    echo "name" > $DIR/names.txt

    #####cut -f1 $file | tail -n +2  >> ${DIR}/names.txt
    # megahit needs this:
    cat $OUTDIR/$EXPNAME/$SNAME/long_contigs_$L.fa | grep '>'    | sed -e 's/ /_/g' | sed -e 's/>//g' >> ${DIR}/names.txt


    for file in $DIR/*_depl_kallisto_${K2}_out/abundance.tsv; do
        echo $file 
        echo $file > ${file%abundance.tsv}est_counts.txt
        cut -f4 $file | tail -n +2 >> ${file%abundance.tsv}est_counts.txt
    done

    mkdir -p $DIR/$NAME
    paste -d '\t' $DIR/names.txt $DIR/*_depl_kallisto_${K2}_out/est_counts.txt > $DIR/$NAME/counts.txt
fi

if [ "$EXPNAME" = "megahit_results" ]; then 
    #python filter_counts_before_deseq.py -i $DIR/$NAME/counts.txt -o $DIR/$NAME/counts_filtered.txt  --maxlen 1500 --minlen 500
    pass
else 
    #velvet and metavelvet needs adjustment
    K3=${EXPNAME#*'_'}
    #K3=  #remove all after _
    K3=${K3%'_'*}
    echo "adjusting lengths for $EXPNAME by ${K3}" 
    #python filter_counts_before_deseq.py -i $DIR/$NAME/counts.txt -o $DIR/$NAME/counts_filtered.txt  --maxlen $((1500-$K3+1)) --minlen $((500-$K3+1))
fi




FA=/mnt/chr4/mikrobiomy-2/$EXPNAME/$SNAME/long_contigs_$L.fa

OPTS="-c $DIR/$NAME/counts_filtered.txt -w -d -l -m -e -o "



#Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_all4_all16 1 0 1 0 1 0 1 0 1
#python csv_to_tex.py $DIR/$NAME/deseq_all4_all16/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_all4_all16_pvals.tex
#python get_selected_fasta.py -s $DIR/$NAME/deseq_all4_all16/pvals.csv -f $FA -o $DIR/$NAME/deseq_all4_all16/all4_all16_selected.fa -t 'c'
#python get_fasta_by_coverage.py -c $DIR/$NAME/counts_filtered.txt -f $FA -o $DIR/$NAME/deseq_all4_all16/all4_all16_coverage.fa -n 100 --split 1 0 1 0 1 0 1 0 1



#Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_wt_tri 0 0 0 0 0 1 1 1 1
#python csv_to_tex.py $DIR/$NAME/deseq_wt_tri/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_wt_tri_pvals.tex
#python get_selected_fasta.py -s $DIR/$NAME/deseq_wt_tri/pvals.csv -f $FA -o $DIR/$NAME/deseq_wt_tri/wt_tri_selected.fa -t 'c'
#python get_fasta_by_coverage.py -c $DIR/$NAME/counts_filtered.txt -f $FA -o $DIR/$NAME/deseq_wt_tri/wt_tri_coverage.fa -n 100 --split  0 0 0 0 0 1 1 1 1

#Rscript run_diffexprs.R $OPTS $DIR/$NAME/deseq_wt4_wt16 1 0 1 0 1 - - - -
#python csv_to_tex.py $DIR/$NAME/deseq_wt4_wt16/pvals.csv /mnt/chr3/People/Julia/mikrobiomy/${EXPNAME}_${NAME}_wt4_wt16_pvals.tex
#python get_selected_fasta.py -s $DIR/$NAME/deseq_wt4_wt16/pvals.csv -f $FA -o $DIR/$NAME/deseq_wt4_wt16/wt4_wt16_selected.fa -t 'c'
#python get_fasta_by_coverage.py -c $DIR/$NAME/counts_filtered.txt -f $FA -o $DIR/$NAME/deseq_wt4_wt16/wt4_wt16_coverage.fa -n 100 --split  1 0 1 0 1 2 2 2 2


#dla Ilony
EXPNAME2=$EXPNAME
ILONA="/mnt/chr4/mikrobiomy-2/dla_Ilony"
if [ "$EXPNAME" = "megahit_results" ]; then
    EXPNAME2="megahit"
fi
if [ "$EXPNAME" = "metavelvet_31" ]; then
    EXPNAME2="metavelvet31"
fi

for test in wt_tri all4_all16 ; do
    #cp -i $DIR/$NAME/deseq_${test}/${test}_selected.fa $ILONA/${EXPNAME2}_${test}_selected.fa
    #cp -i $DIR/$NAME/deseq_${test}/pvals.csv $ILONA/${EXPNAME2}_${test}_pvals.csv    
    #cp -i $DIR/$NAME/deseq_${test}/${test}_coverage.fa $ILONA/${EXPNAME2}_${test}_coverage.fa

    
    #cp -i $DIR/../../long_contigs_200.fa $ILONA/${EXPNAME2}/
    cp -i $DIR/$NAME/counts_filtered.txt $ILONA/${EXPNAME2}/filtered_counts_kallisto21.txt
    #cp -i $DIR/$NAME/counts.txt $ILONA/${EXPNAME2}/raw_counts_kallisto21.txt
    #cp -i $DIR/$NAME/deseq_${test}/${test}_selected.fa $ILONA/${EXPNAME2}/${test}_selected.fa
    #cp -i $DIR/$NAME/deseq_${test}/pvals.csv $ILONA/${EXPNAME2}/${test}_pvals.csv
done


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


