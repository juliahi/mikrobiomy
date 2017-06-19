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

# Genomy z CLARK:
# 


# Kallisto
#./run_kallisto_k.sh $K
#./run_kallisto_pseudo.sh 

# Podsumowanie estymowanej liczby odczytów:
#python kallisto_table.py -c $VALUE -n $MISS -t $OPTION -k $K
# Pełna tabela
#python kallisto_table.py -c 0 -n 6 -t $OPTION -k $K

mkdir -p $DIR/$NAME

# # # Wybór genomów z najwiekszą liczbą readów
#python find_abundant.py -c $VALUE -n $MISS -t $OPTION -k $K
# ## zapisuje plik txt z wybranymi GI


# tabelka częstości wszystkich wybranych w oryginalnym mapowaniu kallisto
sh count_pseudoal.sh $OPTION $VALUE  $MISS  $K


# Różnicowa obecność genomów
python differential_abundance.py  -t $OPTION -c $VALUE -n $MISS -k $K
python differential_abundance_aggregate.py  -t $OPTION -c $VALUE -n $MISS -k $K


# różnicowa obecność genomów w danych Ilony z uclust
#python differential_other.py -l 2
#python differential_other.py -l 3

# Dane z genbanka:
# wynikowy plik txt tutaj ->  http://www.ncbi.nlm.nih.gov/sites/batchentrez
# dostaje się plik gb
# echo "Run in http://www.ncbi.nlm.nih.gov/sites/batchentrez and download "Genbank full""
# read INPUT 

## Mapowanie Bowtie2:
# bash bowtie_map_to_selected.sh $NAME
## robi również sortowanie i index, przygotowuje wcześniej genomy


# # # Adnotacja do gff:

# python prepare_gff.py $NAME
# python change_gff.py $NAME
# 
# # # # Zliczanie
# bash htseq_and_deseq.sh $NAME



################################# Assemblacja #####################################################3


# Oases:
sh oases_all.sh # robi kontigi
sh kallisto_on_oases.sh 21 all mergedAssembly  #kallisto k=21
sh kallisto_on_oases.sh 21 all all_31  #kallisto k=21
sh kallisto_on_oases.sh 21 all all_31_conf  #kallisto k=21
python compare_mappability.py

sh bowtie_on_contigs.sh oases #bowtie



