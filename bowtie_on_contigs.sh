#run after oases_all or velvet_all

K1=31
K2=21
L=200 #contig length

#NAME="all"
NAME="6685_04-06-2015_depl"




if [ "$1" = "oases" ]; then
    OUTDIR=/mnt/chr4/mikrobiomy-2/oases_${K1}_$K2/$NAME
else
    OUTDIR=/mnt/chr4/mikrobiomy-2/velvet_${K1}/$NAME
fi
INDIR=/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed

LOG=$OUTDIR/logging.txt




####### mapping bowtie

BOWTIEDIR="/home/julia/bowtie2-2.2.9"
#DIR=/mnt/chr7/data/julia

mkdir -p $OUTDIR/bowtie

if [ ! -f $OUTDIR/bowtie/${NAME}.1.bt2 ]; then
    if [ "$1" = "oases" ]; then
	cd $OUTDIR/bowtie; $BOWTIEDIR/bowtie2-build -f $OUTDIR/mergedAssembly/transcripts.fa $NAME   >> $OUTDIR/bowtie/mapping.log  #### oases
    else
	cd $OUTDIR/bowtie; $BOWTIEDIR/bowtie2-build -f $OUTDIR/long_contigs_$L.fa $NAME	  >> $OUTDIR/bowtie/mapping.log   ##### velvet
    fi
fi
exit
INDIR="/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed"

for file in $INDIR/6685*_depl_1.fq.gz; do
    FILENAME=${file%_1.fq.gz}
    OUTNAME=$OUTDIR/bowtie/`basename $FILENAME`.sam
    echo $OUTNAME $file
    if [ ! -f $OUTNAME ]; then
        echo $OUTNAME >> $OUTDIR/bowtie/mapping.log

        $BOWTIEDIR/bowtie2 -x $OUTDIR/bowtie/$NAME -p 8 -N 1 -1 $file -2 ${FILENAME}_2.fq.gz -S $OUTNAME 2>>$OUTDIR/bowtie/mapping.log
    fi
    if [ ! -f ${OUTNAME}.bam ]; then
        samtools view -bS $OUTNAME > ${OUTNAME}.bam
    fi
    if [ ! -f ${OUTNAME}_sorted.bam.bai ]; then
        #samtools sort -f ${OUTNAME}.bam ${OUTNAME}_sorted.bam
        samtools sort -@ 2 ${OUTNAME}.bam ${OUTNAME}_sorted 
        samtools index ${OUTNAME}_sorted.bam
    fi
done

