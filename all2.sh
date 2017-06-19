

################# Modify kallisto to diagnose ###############

#see why not mapping - write stats to chr7/kallisto_stats/probename_out/stats.txt

#sh kallisto_with_stats.sh 13
#sh kallisto_with_stats.sh 21
#sh kallisto_with_stats.sh 25
#sh kallisto_with_stats.sh 31


#BLAST some of reads -- select few not mapping
#python summarize_stats_prepare_blast.py 31 #13 21 25

#TODO


#run_blast.sh 13
#...

#mapping to assemblied transcripts (VELVET)
#sh velvet_all.sh 21 &
#sh velvet_all.sh 25 &
#sh velvet_all.sh 31 &



#mappability - Venn diagrams how many reads mappable for every sample and for all
python compare_mappability.py

#Deseq

sh deseq_all.sh 21
sh deseq_all.sh 25
sh deseq_all.sh 31

####################### de-novo assemblies ##################################




############## Summarize assemblies etc: ##########################

#table of mappability (unique), not mapped by k-mers, not mapped by conflicts etc.
# results in chr4/not_mapping_name*.tsv, .tex
#python why_not_mapping.py 13 21 25 31


