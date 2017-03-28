
K=31
L=200 #lenght of contig
K2=$1


NAME="6685_04-06-2015_depl"
#NAME="all"


OUTDIR=/mnt/chr4/mikrobiomy-2/velvet_${K}
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

INFILES1=`echo $INDIR/*depl_*.gz`

### assembly
#velvet_1.2.10/velveth $OUTDIR/$NAME $K -fastq -shortPaired -separate $INFILES1  > $OUTDIR/$NAME.txt
#wait
#velvet_1.2.10/velvetg $OUTDIR/$NAME/ -cov_cutoff 5 -ins_length 200 -exp_cov 2  > $OUTDIR/$NAME.txt
#wait
#python after_velvet.py -i $OUTDIR/$NAME/stats.txt -o $OUTDIR/$NAME/hists.pdf -c 1


#kallisto:
#sh kallisto_on_velvet.sh $K2






