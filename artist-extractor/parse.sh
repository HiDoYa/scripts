#!/bin/bash

rm -rf authors cat_songs titles

mkdir cat_songs
awk -f split.awk songs.txt

mkdir titles
for i in {0..12}; do 
	awk -f compl.awk cat_songs/cat_song${i}.txt > titles/titles${i}.txt; 
done

mkdir authors
for i in {0..12}; do 
	awk -f authors.awk titles/titles${i}.txt > authors/temp_authors${i}.txt; 
done

for i in {0..12}; do 
	cat authors/temp_authors${i}.txt \
		| uniq -c | sort -r \
		| sed "s/^ *[0-9]\{1,\} //" > authors/authors${i}.txt; 
done
rm authors/temp_authors*

# Sed 1: remove leading ./
# Sed 2: remove ending :
# Sed 3: remove pathname (if exists)
for i in {0..12}; do 
	head -n 1 cat_songs/cat_song${i}.txt \
		| sed 's/\.\///' | sed 's/://' | sed 's/^.*\///' \
		| xargs -t -I '{}' /bin/bash -c \
		"mv authors/authors${i}.txt authors/{}.txt && mv titles/titles${i}.txt titles/{}.txt && mv cat_songs/cat_song${i}.txt cat_songs/{}.txt";
done

