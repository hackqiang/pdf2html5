#!/bin/bash
#sudo apt-get install imagemagick inkscape pdf2svg

mkdir log

if [ ! $1 ]; then
	echo "usage: ./batch.sh folder_contains_pdf pages"
	exit
fi

for files in `find $1 -name *.pdf`
do
	echo "make $files"
	./pdf2html.sh $files $2 > log/`basename ${files} .pdf`.log 2>&1
done

