#WYMAGANIA
# biopython
# ht-seq

OPTION=est_counts
VALUE=1000
MISS=1
K=13

DIR=/mnt/chr7/data/julia

NAME=${OPTION}${K}_${VALUE}_${MISS}


source ~/venv/bin/activate

# Genomy z:
# ...


# Kallisto
#./run_kallisto_k.sh $K
#./run_kallisto_pseudo.sh 

# Podsumowanie estymowanej liczby odczytów:
python kallisto_table.py -c $VALUE -n $MISS -t $OPTION -k $K
# Pełna tabela
#python kallisto_table.py -c 0 -n 6 -t $OPTION -k $K

mkdir -p $DIR/$NAME

# # # Wybór genomów z najwiekszą liczbą readów
python find_abundant.py -c $VALUE -n $MISS -t $OPTION -k $K
# ## zapisuje plik txt z wybranymi GI


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

# Mapowanie Bowtie2:
# bash map.sh $NAME
# robi również sortowanie i index, przygotowuje wcześniej genomy


# # # Adnotacja do gff:

# python prepare_gff.py $NAME
# python change_gff.py $NAME
# 
# # # # Zliczanie
# bash htseq_and_deseq.sh $NAME






