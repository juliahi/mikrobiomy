PROBE=$1
DIR=/mnt/chr7/data/JakubPoziemski/$PROBE

mkdir -p $DIR
mkdir -p $DIR/metavelvet31
mkdir -p $DIR/metavelvet21
mkdir -p $DIR/velvet31
mkdir -p $DIR/oases
mkdir -p $DIR/megahit
mkdir -p $DIR/sga



if [ ! -f $DIR/metavelvet31/pseudoal.bam ];
then
	samtools view -bS -F 4 /mnt/chr4/mikrobiomy-2/metavelvet_31/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam > $DIR/metavelvet31/pseudoal.bam
	samtools view -bS -F 4 /mnt/chr4/mikrobiomy-2/metavelvet_21/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam > $DIR/metavelvet21/pseudoal.bam
	samtools view -b -F 4 /mnt/chr4/mikrobiomy-2/velvet_31/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out/pseudoal.bam > $DIR/velvet31/pseudoal.bam
	samtools view -bS -F 4 /mnt/chr4/mikrobiomy-2/oases_31_21/all_covcut/all_31_conf/kallisto_on_contigs_200/all_covcut_all_31_conf_21/$PROBE-06-2015_depl_kallisto_21_out.sam > $DIR/oases/pseudoal.bam
	samtools view -b -F 4 /mnt/chr4/mikrobiomy-2/megahit_results/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out_pseudoal.bam > $DIR/megahit/pseudoal.bam
	samtools view -b -F 4 /mnt/chr7/data/julia/sga/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out_pseudoal.bam > $DIR/sga/pseudoal.bam
fi


samtools view -F 0x4 /mnt/chr4/mikrobiomy-2/metavelvet_31/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv

samtools view -F 0x4 /mnt/chr4/mikrobiomy-2/metavelvet_21/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv

samtools view -F 0x4 /mnt/chr4/mikrobiomy-2/velvet_31/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out/pseudoal.bam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv

samtools view -F 0x4 /mnt/chr4/mikrobiomy-2/oases_31_21/all_covcut/all_31_conf/kallisto_on_contigs_200/all_covcut_all_31_conf_21/$PROBE-06-2015_depl_kallisto_21_out.sam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv

samtools view -F 0x4 /mnt/chr4/mikrobiomy-2/megahit_results/all/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv

samtools view -F 0x4 /mnt/chr7/data/julia/sga/kallisto_on_contigs_200/all_21/$PROBE-06-2015_depl_kallisto_21_out.sam | cut -f 1 | sort | uniq | wc -l >> $DIR/mapped.tsv



exit



for name in metavelvet21  metavelvet31 oases velvet31;
do	
	
	cd $DIR/$name; samtools sort pseudoal.bam > pseudoal_sorted.bam
	cd $DIR/$name; samtools index pseudoal_sorted.bam > pseudoal_sorted.bam.bai
	echo $name
done

