
K=$1
L=200 #lenght of contig

NAME=$2

OUTDIR=/mnt/chr4/mikrobiomy-2/velvet_${K}
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*`



########### RUN VELVET ##################


#velvet_1.2.10/velveth $OUTDIR/$NAME $K -fastq -shortPaired -separate $INFILES1  > $OUTDIR/$NAME.txt
#wait
#velvet_1.2.10/velvetg $OUTDIR/$NAME/ -cov_cutoff 5 -ins_length 200 -exp_cov 2  > $OUTDIR/$NAME.txt
#wait
#python after_velvet.py -i $OUTDIR/$NAME/stats.txt -o $OUTDIR/$NAME/hists.pdf -c 1



##### filter, summarize, etc ###########

#python select_contigs.py $OUTDIR/$NAME/contigs.fa $OUTDIR/$NAME/long_contigs_$L.fa $L

SUM=$OUTDIR/summary.txt
python get_seqlengths_from_fasta.py $OUTDIR/${NAME}/long_contigs_$L.fa $OUTDIR/${NAME}/longcontigs_stats.txt 


echo " VELVET K=$K CONTIGS" >> $SUM
python after_velvet.py -i $OUTDIR/${NAME}/longcontigs_stats.txt -o $OUTDIR/${NAME}/hists_longcontigs.pdf -c 1 >> $SUM

python summarize_assemblies.py $OUTDIR/$NAME/longcontigs_stats.txt 1


