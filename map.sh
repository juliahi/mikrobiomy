
echo "usage: map.sh ANALYSISNAME"
BOWTIEDIR="/home/julia/bowtie2-2.2.9"
DIR=/mnt/chr7/data/julia

NAME=$1
GIS=selected_gis_${NAME}.txt

#cat $GIS | while read ID
#do
#	echo $ID
#	for file in $DIR/Bacteria/*/$ID.fna; do
#	    bowtie2-build $file  
#	    
#	done
#done
FILES=()
mkdir -p $DIR/$NAME

while read ID
do
	for file in "$DIR/Bacteria/*/$ID.fna"; do
            FILES+=($file)
	done
done < "$DIR/$GIS"

if [ ! -f $DIR/$NAME/genomes_${NAME}.fna ]; then
    while read ID
    do
	for file in "$DIR/Bacteria/*/$ID.fna"; do
            cat $file >> $DIR/$NAME/genomes_${NAME}.fna
	done
    done < "$DIR/$GIS"
fi

echo ${FILES[@]}

function join { local IFS="$1"; shift; echo "$*"; }

#cd $DIR; $BOWTIEDIR/bowtie2-build -f `join , ${FILES[@]}` ${GIS/.txt/}


INDIR="/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed"

for file in $INDIR/*_depl_1.fq.gz; do
    OUTNAME=$DIR/$NAME/`basename ${file/_1.fq.gz}`.sam
    if [ ! -f $OUTNAME ]; then
        echo $OUTNAME >> $DIR/$NAME/mapping.log

        $BOWTIEDIR/bowtie2 -x $DIR/${GIS/.txt/} -p 8 -N 1 -1 $file -2 ${file/depl_1/depl_2} -S $OUTNAME 2>>$DIR/$NAME/mapping.log
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

