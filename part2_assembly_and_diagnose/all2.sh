
#source ~/venv/bin/activate

#export OUTDIR=/mnt/chr4/mikrobiomy-2/results
export OUTDIR=/home/julia/mikrobiomy_results
export INDIR=/home/julia/Wyniki_sekwencjonowania
#export INDIR=/home/julia/Wyniki_sekwencjonowania/depl_filtered
export MINCONTIGLENGTH=200

mkdir -p $OUTDIR/img

################# Modify kallisto to diagnose ###############
## Prepare genone
##DIR=/mnt/chr7/julia
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
#echo `date` "running velvet with run_velvet.sh"
#cat run_velvet.sh 
#sh run_velvet.sh 21 all 
##sh run_velvet.sh 25 all 
#sh run_velvet.sh 31 all 
#wait

#sh kallisto_on_assembly.sh 21 velvet_21 all
#sh kallisto_on_assembly.sh 21 velvet_31 all &


#### OASES ####
#echo `date` "running oases with run_oases.sh"
#cat run_oases.sh 
#sh run_oases.sh 31 21 all 

#sh kallisto_on_assembly.sh 21 oases_31_21 "all/mergedAssembly"
#wait


##### METAVELVET #########

#sh run_metavelvet.sh 21 all &
#sh run_metavelvet.sh 31 all &

#sh kallisto_on_assembly.sh 21 metavelvet_21 "all"
#sh kallisto_on_assembly.sh 21 metavelvet_31 "all"

##sh diffexpr_all.sh 21 metavelvet_31 all


#### VELVET plain -- default settings ####
#sh run_velvet_plain.sh 31 all 
#sh kallisto_on_velvet_plain.sh 21 velvet_31_plain all 
#python why_not_mapping.py $OUTDIR/velvet_31_plain/all/kallisto_on_contigs_200/all_21 $OUTDIR/not_mapping_velvet31_plain  21
#sh diffexpr_all.sh 21 velvet_31_plain all



######## Megahit ##########

#sh megahit_all.sh  &

#sh kallisto_on_megahit.sh 21
#sh diffexpr_all.sh 21 megahit_results all


####### IDBA-UD ##########

sh idbaud_all.sh

sh kallisto_on_assembly.sh 21 idba_ud all
##sh diffexpr_all.sh 21 idba_ud all




#mappability - Venn diagrams how many reads mappable for every sample and for all
#python compare_mappability.py


