
K=$1
L=$MINCONTIGLENGTH
NAME=$2

EXPNAME=velvet_${K}

OUTDIR=$OUTDIR/$EXPNAME
mkdir -p $OUTDIR
INFILES1=`echo $INDIR/*depl_?.fq.gz`
########### RUN VELVET ##################

~/velvet_1.2.10/velveth $OUTDIR/$NAME $K -fastq -shortPaired -separate $INFILES1  > $OUTDIR/$NAME.txt
~/velvet_1.2.10/velvetg $OUTDIR/$NAME/ -cov_cutoff 5 -ins_length 200 -exp_cov 2  > $OUTDIR/$NAME.txt
python after_velvet.py -i $OUTDIR/$NAME/stats.txt -o $OUTDIR/$NAME/hists.pdf -c 1

##### filter, summarize, etc ###########

python select_contigs.py $OUTDIR/$NAME/contigs.fa $OUTDIR/$NAME/long_contigs_$L.fa $L
SUM=$OUTDIR/summary.txt
python get_seqlengths_from_fasta.py $OUTDIR/${NAME}/long_contigs_$L.fa $OUTDIR/${NAME}/longcontigs_stats.txt 

echo " VELVET K=$K CONTIGS" >> $SUM
python after_velvet.py -i $OUTDIR/${NAME}/longcontigs_stats.txt -o $OUTDIR/${NAME}/${EXPNAME}_hists_longcontigs.pdf -c 1 >> $SUM
python summarize_assemblies.py $OUTDIR/$NAME/longcontigs_stats.txt 1


cp $OUTDIR/${NAME}/${EXPNAME}_hists_longcontigs.pdf $OUTDIR/img/${EXPNAME}_hists_longcontigs.pdf
