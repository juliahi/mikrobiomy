



#for PROBE in 6683_16 6685_04 6695_04 6695_16 6690_04 6690_16 6704_04 6704_16;   #
#do
#	sudo su writer -c "sh copy_data.sh $PROBE" &
#	sleep 5
#done
#wait


INDIR="/mnt/chr7/data/JakubPoziemski"
OUTDIR="/mnt/chr4/mikrobiomy-2/results/Jaccard"

mkdir -p $OUTDIR

echo "\nmetavelvet31\nmetavelvet21\nvelvet31\noases\nmegahit\nsga" > mapped.csv
for PROBE in 6683_16 6685_04 6685_16 6690_04 6690_16 6695_04 6695_16 6704_04 6704_16;   #
do
	echo "$PROBE" > tmp.csv
	cat "$INDIR/$PROBE/mapped.tsv" >> tmp.csv
	paste -d',' mapped.csv tmp.csv > mapped2.csv
	mv mapped2.csv mapped.csv
done
rm tmp.csv
wait
mv mapped.csv $OUTDIR/mapped.csv

for PROBE in 6683_16 6685_04 6685_16 6690_04 6690_16 6695_04 6695_16 6704_04 6704_16 ;
do
	#for name in metavelvet21  metavelvet31 oases velvet31 ;
	for name in  metavelvet31 velvet31 megahit sga;
	do	
		if [ ! -f "$OUTDIR/${PROBE}_${name}ZbOdczytow.pickle" ]; then

			time python create_dict.py "$INDIR/$PROBE/$name/pseudoal.bam" ${PROBE}_$name "$OUTDIR" &
			echo $name
			echo "" > ${OUTDIR}/${PROBE}_index.txt
		fi
	done
done
wait 

#for pair in "metavelvet31,metavelvet21" "metavelvet31,velvet31" "metavelvet31,oases" "metavelvet21,velvet31" "metavelvet21,oases" "velvet31,oases";
for pair in "metavelvet31,velvet31" "metavelvet31,sga" "metavelvet31,megahit" "velvet31,sga" "velvet31,megahit" "sga,megahit";
do
  	name1=`echo "$pair" | cut -d',' -f1`
  	name2=`echo "$pair" | cut -d',' -f2`
	if [ $name1 != $name2 ]; then
		for PROBE in 6683_16 6685_04 6685_16 6690_04 6690_16 6695_04 6695_16 6704_04 6704_16 ;
		do
			echo $PROBE, $name1, $name2 
			#python IndexJaccarda.py ${PROBE} $name1 $name2 "$OUTDIR" >> ${OUTDIR}/${PROBE}_index.txt &
			#python contigi.py ${PROBE}_$name1 ${PROBE}_$name2 100 "$OUTDIR" &
		done
		wait
	fi
done
wait

	

echo "probe\tname1\tname2\tcommonreads\t%common1\t%common2\ts11\ts10\ts01\tJaccardindex" > ${OUTDIR}/index.csv

for PROBE in 6683_16 6685_04 6685_16 6690_04 6690_16 6695_04 6695_16 6704_04 6704_16 ;
do
	#echo '\n' >> ${OUTDIR}/${PROBE}_index.txt
	#echo ${PROBE} >> ${OUTDIR}/index.txt
	cat ${OUTDIR}/${PROBE}_index.txt >> ${OUTDIR}/index.txt
	#echo ${PROBE} >> ${OUTDIR}/index.csv
	cat ${OUTDIR}/${PROBE}_index.txt >> ${OUTDIR}/index.csv
done

python plot.py "$OUTDIR"



