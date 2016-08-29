BOWTIEDIR="/home/julia/bowtie2-2.2.9"
DIR=/mnt/chr7/data/julia

NAME=est_counts_10000_1
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
while read ID
do
	for file in "$DIR/Bacteria/*/$ID.fna"; do
            FILES+=($file)
	done
done < "$DIR/$GIS"

echo ${FILES[@]}

function join { local IFS="$1"; shift; echo "$*"; }

#cd $DIR; $BOWTIEDIR/bowtie2-build -f `join , ${FILES[@]}` ${GIS/.txt/}


INDIR="/mnt/chr4/mikrobiomy-2/Wyniki_sekwencjonowania/demultiplexed"
mkdir -p $DIR/$NAME

for file in $INDIR/*_depl_1.fq.gz; do
    OUTNAME=$DIR/$NAME/`basename ${file/_1.fq.gz}`.sam
    if [ ! -f $OUTNAME ]; then
        echo $OUTNAME >> $DIR/$NAME/mapping.log

        $BOWTIEDIR/bowtie2 -x $DIR/${GIS/.txt/} -p 8 -N 1 -1 $file -2 ${file/depl_1/depl_2} -S $OUTNAME 2>>$DIR/$NAME/mapping.log
    fi
    samtools view -bS $OUTNAME > ${OUTNAME}.bam

done

