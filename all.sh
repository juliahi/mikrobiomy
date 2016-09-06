#WYMAGANIA
# biopython
# ht-seq

OPTION=est_counts
VALUE=10000
MISS=1
K=21

DIR=/mnt/chr7/data/julia

NAME=${OPTION}_${VALUE}_${MISS}

# Genomy z:
# ...


# Kallisto
# ./run_kallisto_k.sh 21

# Podsumowanie estymowanej liczby odczytów:
# python kallisto_table.py -c $VALUE -n $MISS -t $OPTION
# Pełna tabela
# python kallisto_table.py -c 0 -n 6 -t $OPTION

# Różnicowa obecność genomów
python differential_abundance.py  -t $OPTION -c $VALUE -n $MISS

mkdir -p $DIR/$NAME
# Wybór genomów z najwiekszą liczbą readów
python find_abundant.py -c $VALUE -n $MISS -t $OPTION
## zapisuje plik txt z wybranymi GI

# Dane z genbanka:
# wynikowy plik txt tutaj ->  http://www.ncbi.nlm.nih.gov/sites/batchentrez
# dostaje się plik gb
# echo "Run in http://www.ncbi.nlm.nih.gov/sites/batchentrez and download "Genbank full""
# read INPUT 

# Mapowanie Bowtie2:
# bash map.sh $NAME
# robi również sortowanie i index, przygotowuje wcześniej genomy


# # # Adnotacja do gff:

python prepare_gff.py $NAME
python change_gff.py $NAME

# # # Zliczanie
bash htseq_and_deseq.sh $NAME







