NAME=$1
DIR="/mnt/chr7/data/julia"

#grep -v "pseudo" $DIR/$NAME/selected_gis_${NAME}.gff > $DIR/$NAME/selected_gis_${NAME}_nopseudo.gff

START=true
for file in $DIR/$NAME/*.sam_sorted.bam; do
    echo $file
    OUTNAME=${file/.sam_sorted.bam/.counts}
    if [ ! -f $OUTNAME ]; then
         htseq-count -f bam -r pos -s no -t gene -i locus_tag -a 0  $file  $DIR/$NAME/selected_gis_${NAME}_nopseudo.gff > $OUTNAME
    fi
    #sort -n -k 2 $OUTNAME  | tail 
    if $START ; then
         echo "$file" > $DIR/$NAME/counts_all.txt
         cat $OUTNAME >> $DIR/$NAME/counts_all.txt
    else
         echo "$file" > $DIR/$NAME/tmp.txt
         cut -f2 $OUTNAME >> $DIR/$NAME/tmp.txt
         paste $DIR/$NAME/counts_all.txt $DIR/$NAME/tmp.txt > $DIR/$NAME/tmp2.txt
         cat $DIR/$NAME/tmp2.txt > $DIR/$NAME/counts_all.txt
         rm $DIR/$NAME/tmp.txt
         rm $DIR/$NAME/tmp2.txt
    fi
    START=false
done


python -c "import sys; [sys.stdout.write(line) for line in open('$DIR/$NAME/counts_all.txt') if (not line[0]=='_') and (not line.split('\t')[1].isdigit() or sum([int(x) for x in line.split('\t')[1:]]) >= 3)] "  > $DIR/$NAME/counts.txt

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
