#!/bin/bash
#sudo apt-get install imagemagick inkscape pdf2svg

if [ ! $1 ]; then
	echo "usage: ./pdf2html.sh pdffile pages"
	exit
fi

pages=100000
if [ $2 ]; then
	pages=$2
fi

output=output/`basename $1 .pdf`
img_output=$output/page_images
svg_output=tmp/`basename $1 .pdf`

output_width=720

rm -rf $svg_output
mkdir -p $svg_output

rm -rf $output
mkdir -p $img_output

cp -rf template/{css,js} $output

for ((i=0; i<$pages; ++i))
do
	echo "make page $i/$pages"
	pdf2svg $1 $svg_output/page$i.svg $[ $i+1 ]
	if [ $? != 0 ]; then 
		break
	fi
	inkscape -w$output_width -b white -f $svg_output/page$i.svg -e $img_output/page$i.jpg
	mogrify -format jpg -quality 100 -resize x160 -write $img_output/page${i}_th.jpg $svg_output/page$i.svg

	if [ $i == 0 ]; then
		echo "<div class='cover' data-background-file='page_images/page${i}.jpg' data-thumbnail-image='page_images/page${i}_th.jpg' data-page-label='t${i}'></div>" >> $svg_output/pages.info
	else
		echo "<div class='page' data-background-file='page_images/page${i}.jpg' data-thumbnail-image='page_images/page${i}_th.jpg' data-page-label='t${i}'></div>" >> $svg_output/pages.info
	fi
done

#check the image size
PageWidth=`identify $img_output/page4.jpg | sed "s/x/\ /g" | awk '{print $3}'`
PageHeight=`identify $img_output/page4.jpg | sed "s/x/\ /g" | awk '{print $4}'`
ThumbnailWidth=`identify $img_output/page4_th.jpg | sed "s/x/\ /g" | awk '{print $3}'`
ThumbnailHeight=`identify $img_output/page4_th.jpg | sed "s/x/\ /g" | awk '{print $4}'`
echo page size ${PageWidth}x${PageHeight} ${ThumbnailWidth}x${ThumbnailHeight}

cat template/index1.html > $output/index.html
cat $svg_output/pages.info >> $output/index.html
cat template/index2.html >> $output/index.html

#REPLACE_PDF_NAME
sed -i "s/REPLACE_PDF_NAME/`basename $1 .pdf`/g" $output/index.html
#REPLACE_PAGEWIDTH
#REPLACE_PAGEHEIGHT
#REPLACE_THUMBNAILWIDTH
#REPLACE_THUMBNAILHEIGHT
sed -i "s/REPLACE_PAGEWIDTH/$PageWidth/g" $output/index.html
sed -i "s/REPLACE_PAGEHEIGHT/$PageHeight/g" $output/index.html
sed -i "s/REPLACE_THUMBNAILWIDTH/$ThumbnailWidth/g" $output/index.html
sed -i "s/REPLACE_THUMBNAILHEIGHT/$ThumbnailHeight/g" $output/index.html

