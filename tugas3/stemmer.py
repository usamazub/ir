#!/usr/bin/python3

import sys

# import StemmerFactory class
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory

# create stemmer
factory = StemmerFactory()
stemmer = factory.create_stemmer()

# stemming process
sentence = " ".join(sys.argv[1:])
output   = stemmer.stem(sentence) + '\n'

f = open("hasil_stem.txt", "w")
f.write(output)
f.close()
