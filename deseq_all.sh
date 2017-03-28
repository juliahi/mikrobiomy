
K=31
L=200 #lenght of contig
K2=$1




DIR=/mnt/chr4/mikrobiomy-2/kallisto_on_contigs/${K}_${L}
LOGFILE=$DIR/kallisto_${K2}.log

file=$DIR/6683_16-06-2015_depl_kallisto_${K2}_out/abundance.tsv
echo "name" > $DIR/names.txt
cut -f1 $file | tail -n +2 >> ${DIR}/names.txt

for file in $DIR/*_depl_kallisto_${K2}_out/abundance.tsv; do
    echo $file 
    echo $file > ${file%abundance.tsv}est_counts.txt
    cut -f4 $file | tail -n +2 >> ${file%abundance.tsv}est_counts.txt
done


#for file in $DIR/*_04-06-2015_depl_kallisto_${K2}_out/est_counts.txt; do
#    FILENAME=${file%_04-06-2015_depl_kallisto_${K2}_out/est_counts.txt}
#    
#    echo $FILENAME
#    paste $file ${file//04-06-2015/16-06-2015} > ${FILENAME}.counts
#    run_deseq.R $DIR/${FILENAME}.counts $DIR/${FILENAME}_deseq.csv  $DIR/${FILENAME}_deseq.pdf local 0 1
#done



NAME="deseq_${K2}"
mkdir -p $DIR/$NAME
echo "name" DIR/*_depl_kallisto_${K2}_out > $DIR/$NAME/counts.txt
paste -d '\t' $DIR/names.txt $DIR/*_depl_kallisto_${K2}_out/est_counts.txt >> $DIR/$NAME/counts.txt



Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt4_wt16.tsv $DIR/$NAME/deseq_wt4_wt16.pdf parametric 1 0 1 0 1 - - - -
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_tri4_tri16.tsv $DIR/$NAME/deseq_tri4_tri16.pdf parametric - - - - - 0 1 0 1
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt_tri.tsv $DIR/$NAME/deseq_wt_tri.pdf parametric 0 0 0 0 0 1 1 1 1
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt4_tri4.tsv $DIR/$NAME/deseq_wt4_tri4.pdf parametric - 0 - 0 - 1 - 1 -
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt16_tri16.tsv $DIR/$NAME/deseq_wt16_tri16.pdf parametric 0 - 0 - 0 - 1 - 1




Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt4_wt16_local.tsv $DIR/$NAME/deseq_wt4_wt16_local.pdf local 1 0 1 0 1 - - - -
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_tri4_tri16_local.tsv $DIR/$NAME/deseq_tri4_tri16_local.pdf local - - - - - 0 1 0 1
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt_tri_local.tsv $DIR/$NAME/deseq_wt_tri_local.pdf local 0 0 0 0 0 1 1 1 1
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt4_tri4_local.tsv $DIR/$NAME/deseq_wt4_tri4_local.pdf local - 0 - 0 - 1 - 1 -
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_wt16_tri16_local.tsv $DIR/$NAME/deseq_wt16_tri16_local.pdf local 0 - 0 - 0 - 1 - 1


