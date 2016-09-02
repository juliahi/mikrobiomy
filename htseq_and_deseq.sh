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
    sort -n -k 2 $OUTNAME  | tail
    if $START ; then
         echo "$file" > $DIR/$NAME/counts_all.txt
         cat $OUTNAME >> $DIR/$NAME/counts_all.txt
    else
         echo "$file" > $DIR/$NAME/tmp.txt
         cut -f2 $OUTNAME >> $DIR/$NAME/tmp.txt
         paste $DIR/$NAME/counts_all.txt $DIR/$NAME/tmp.txt > $DIR/$NAME/tmp2.txt
         cat $DIR/$NAME/tmp2.txt > $DIR/$NAME/counts_all.txt\
         rm $DIR/$NAME/tmp.txt
         rm $DIR/$NAME/tmp2.txt
    fi
    START=false
done


#python -c "for line in open('$DIR/$NAME/counts_all.txt'): if sum([int(x) for x in line.split('\t')[1:]]) >= 10: print line" > $DIR/$NAME/counts.txt
python -c "import sys; [sys.stdout.write(line) for line in open('$DIR/$NAME/counts_all.txt') if (not line[0]=='_') and (not line.split('\t')[1].isdigit() or sum([int(x) for x in line.split('\t')[1:]]) >= 3)] "  > $DIR/$NAME/counts.txt

Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_trisom.tsv $DIR/$NAME/deseq_trisom.pdf parametric 0 0 0 0 0 1 1 1 1 
Rscript run_deseq.R $DIR/$NAME/counts.txt $DIR/$NAME/deseq_diet.tsv $DIR/$NAME/deseq_diet.pdf parametric 1 0 1 0 1 0 1 0 1
 
