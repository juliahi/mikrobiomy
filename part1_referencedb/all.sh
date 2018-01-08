#WYMAGANIA
# biopython
# ht-seq


################################# WSTĘPNE ANALIZY - kallisto, najczęstsze sekwencje itp ##################################3

OPTION=est_counts
VALUE=5000
MISS=1
K=21

DIR=/mnt/chr7/data/julia

NAME=${OPTION}${K}_${VALUE}_${MISS}


source ~/venv/bin/activate

# Kallisto with pseudoal w probename_out
./run_kallisto_k.sh $K
## old run with pseudoal: w probename_bam
#####./run_kallisto_pseudo.sh $K 

## Podsumowanie estymowanej liczby odczytów, tylko istotne:
python kallisto_table.py -c $VALUE -n $MISS -t $OPTION -k $K
## Pełna tabela
python kallisto_table.py -c 0 -n 6 -t $OPTION -k $K

mkdir -p $DIR/$NAME



# tabelka częstości wszystkich wybranych w oryginalnym mapowaniu kallisto
# na podstawie wygenerowanych bamów
# zapisuje w OPTIONK_VALUE_MISS/kallisto_pseudoal_summary.txt 
sh count_pseudoal.sh $OPTION $VALUE  $MISS  $K


# Różnicowa obecność genomów
# wynik w: differential_abundance_gr1_gr2_type.tsv i kallistoK_OPTION.tsv
python differential_abundance.py  -t $OPTION -c $VALUE -n $MISS -k $K


# różnicowa obecność genomów w danych Ilony z uclust
python differential_otu_on_taxonomy_level.py -l 2
python differential_otu_on_taxonomy_level.py -l 3
python differential_otu_on_taxonomy_level.py -l 4


######################################## Wybór najczęstszych, bowtie  ###################

# # # Wybór genomów z najwiekszą liczbą readów
python find_abundant.py -c $VALUE -n $MISS -t $OPTION -k $K
# ## zapisuje plik txt z wybranymi GI w OPTIONK_VALUE_MISS/selected_gis_OPTIONK_VALUE_MISS.txt

## Dane z Genbank
# wynikowy plik txt tutaj ->  http://www.ncbi.nlm.nih.gov/sites/batchentrez
# dostaje się plik gb
# echo "Run in http://www.ncbi.nlm.nih.gov/sites/batchentrez and download "Genbank full""
# read INPUT 




## Mapowanie Bowtie2:
## robi również sortowanie i index, przygotowuje wcześniej genomy
bash bowtie_map_to_selected.sh $NAME


# # # Adnotacja do gff:
#przygotowuje plik w formacie gff z adnotacją do wybranych genomów
python prepare_gff_from_txt.py $NAME
#filtruje geny, usuwa pseudogeny
python change_gff.py $NAME



# # # # Zliczanie i różnicowa ekspresja w różnych zdefiniowanych grupach próbek
bash htseq_and_deseq.sh $NAME



################################# Assemblacja #####################################################3

#....

