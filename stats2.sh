

OUTDIR=/mnt/chr4/mikrobiomy-2

# why not mapping to Genomes
python why_not_mapping.py /mnt/chr7/data/julia/kallisto_stats $OUTDIR/not_mapping_Bacteria 13 21 25 31

# to contigs
#velvet31 no expcovauto
python why_not_mapping.py /mnt/chr4/mikrobiomy-2/velvet_31/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_metavelvet  13 21 25 31

#metavelvet=velvet31_expcovauto
python why_not_mapping.py /mnt/chr4/mikrobiomy-2/metavelvet_31/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_metavelvet  13 21 25 31

#oases
python why_not_mapping.py /mnt/chr4/mikrobiomy-2/oases_31_21/all_covcut/mergedAssembly/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases  13 21 25 31
python why_not_mapping.py /mnt/chr4/mikrobiomy-2/oases_31_21/all_covcut/all_31/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases_31  13 21 25 31
python why_not_mapping.py /mnt/chr4/mikrobiomy-2/oases_31_21/all_covcut/all_31_conf/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases_31_conf  13 21 25 31
