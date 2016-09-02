#WYMAGANIA
# biopython
# ht-seq

OPTION=est-counts
VALUE=10000
MISS=1
K=21

NAME=$OPTION_$VALUE_$MISS

# Genomy z:
# ...


# Kallisto
# ./run_kallisto_k.sh 21

# Podsumowanie estymowanej liczby odczytów:
# python kallisto_table.py


# Wybór genomów z najwiekszą liczbą readów
python find_abundant.py -c $VALUE -n $MISS -t $OPTION
## zapisuje plik txt z wybranymi GI

# Dane z genbanka:
# wynikowy plik txt tutaj ->  http://www.ncbi.nlm.nih.gov/sites/batchentrez
# dostaje się plik gb

echo "Run in http://www.ncbi.nlm.nih.gov/sites/batchentrez"
read INPUT 


# Mapowanie Bowtie2:
./map.sh $NAME
# robi również sortowanie i index, przygotowuje wcześniej genomy


# Adnotacja do gff:
# wrzucić plik gb tutaj - konwersja do gff, same geny
# http://iubio.bio.indiana.edu/cgi-bin/readseq.cgi
python change_gff.py $NAME

# Zliczanie
./htseq_and_deseq.sh $NAME



