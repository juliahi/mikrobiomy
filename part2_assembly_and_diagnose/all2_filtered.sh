

source ~/venv/bin/activate


export OUTDIR=/mnt/chr7/data/julia2/results_filtered
#export INDIR=/home/julia/Wyniki_sekwencjonowania
export INDIR=/home/julia/Wyniki_sekwencjonowania/depl_filtered
export MINCONTIGLENGTH=200

mkdir -p $OUTDIR/img


##### Preprocessing
#sh ../read_preprocessing.sh



################# Modify kallisto to diagnose ###############
## Prepare genone
##for file in $DIR/Bacteria/*/*.fna; do
##	cat $file >> $GENOMES_FILE
##done


## see why not mapping - write stats to chr7/kallisto_stats/probename_out/stats.txt

#sh kallisto_with_stats.sh 13
#sh kallisto_with_stats.sh 21
#sh kallisto_with_stats.sh 25
#sh kallisto_with_stats.sh 31

## why not mapping to Genomes -- result in $OUTDIR/not_mapping_Bacteria.tex and .tsv
#python why_not_mapping.py $INDIR/kallisto_stats $OUTDIR/not_mapping_Bacteria 13 21 25 31

## BLAST some of reads -- select few not mapping, or mapping non-uniquely etc.
### this will produce results to /mnt/chr4/mikrobiomy-2/blast_non_mapping/*.fasta, *xml 
### for sample 6685_04

#python select_seqs_for_blast.py 13 21 25
#run_blast.sh 13
#run_blast.sh 21
#run_blast.sh 25

### then prepare blast_sum.xml by hand, or write script...





################ De-novo assembly #####################################

#### VELVET ####
echo `date` "running velvet with run_velvet.sh"
cat run_velvet.sh 
sh run_velvet.sh 21 all &
##sh run_velvet.sh 25 all 
sh run_velvet.sh 31 all &
wait


sh kallisto_on_assembly.sh 21 velvet_21 all 
sh kallisto_on_assembly.sh 21 velvet_31 all 



#### OASES ####
#echo `date` "running oases with run_oases.sh"
#cat run_oases.sh 
#sh run_oases.sh 31 21 all 
wait

#sh kallisto_on_assembly.sh 21 oases_31_21 "all/mergedAssembly"
## sh kallisto_on_assembly.sh 21 oases_31_21 "all/all_31" #?


wait


##mapping to assemblied transcripts (VELVET) with k=21
#sh kallisto_on_velvet.sh 21 velvet_31 all
##sh kallisto_on_velvet.sh 31 velvet_31 all

#velvet31 no expcovauto
#python why_not_mapping.py $OUTDIR/velvet_31/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_velvet  21
#python why_not_mapping.py $OUTDIR/velvet_31/all/kallisto_on_contigs_200/all_31 $OUTDIR/not_mapping_velvet31  31

#sh diffexpr_all.sh 21 velvet_31 all
####sh diffexpr_all.sh 31 velvet_31 all

#### VELVET plain -- default settings ####
#sh run_velvet_plain.sh 31 all 
#sh kallisto_on_velvet_plain.sh 21 velvet_31_plain all 
#python why_not_mapping.py $OUTDIR/velvet_31_plain/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_velvet31_plain  21
#sh diffexpr_all.sh 21 velvet_31_plain all

##### METAVELVET #########
#...

#sh run_metavelvet.sh 21 all &
#sh run_metavelvet.sh 31 all &


####metavelvet=velvet31_expcovauto
#python why_not_mapping.py $OUTDIR/metavelvet_31/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_metavelvet31_21  21 
#python why_not_mapping.py $OUTDIR/metavelvet_31/all/kallisto_on_contigs_200/all_31 $OUTDIR/not_mapping_metavelvet31_31  31


#sh diffexpr_all.sh 21 metavelvet_31 all
###sh diffexpr_all.sh 31 metavelvet_31 all







########3 Megahit ##########



#sh megahit_all.sh  &

#sh kallisto_on_megahit.sh 21
#python why_not_mapping.py $OUTDIR/megahit_results/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_megahit  21
#sh diffexpr_all.sh 21 megahit_results all





#mappability - Venn diagrams how many reads mappable for every sample and for all
#python compare_mappability.py

####################### de-novo assemblies ##################################


# to contigs


#oases
#python why_not_mapping.py $OUTDIR/oases_31_21/all_covcut/mergedAssembly/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases  13 21 25 31
#python why_not_mapping.py $OUTDIR/oases_31_21/all_covcut/all_31/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases_31  13 21 25 31
#python why_not_mapping.py $OUTDIR/oases_31_21/all_covcut/all_31_conf/kallisto_on_contigs_200/all*_21 $OUTDIR/not_mapping_oases_31_conf  13 21 25 31



############## Summarize assemblies etc: ##########################

#table of mappability (unique), not mapped by k-mers, not mapped by conflicts etc.
# results in chr4/not_mapping_name*.tsv, .tex
#python why_not_mapping.py 13 21 25 31


