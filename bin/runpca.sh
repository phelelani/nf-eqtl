#!/bin/bash

smartpca.perl -i $1.bed -a $1.bim -b $1.fam -p $1.pca -e $1.eval -o $1.pca -q NO -m 0 -l $1.log
