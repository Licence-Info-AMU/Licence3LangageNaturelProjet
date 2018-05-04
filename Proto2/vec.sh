#!/bin/bash

for part in train-new dev; do
	mkdir -p $part-vec
	for f in $(ls $part/); do
		./doc2vec.sh $part/$f > $part-vec/$f.vec;
	done
done
exit 0
