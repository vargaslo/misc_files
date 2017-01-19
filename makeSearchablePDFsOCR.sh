# requires libtiff-tools tiffcp tiff2pdf tesseract-ocr exactimage?

fileroot='weber_1953'


# Convert pdf to pbm format with 300dpi
pdftoppm -r 300 -mono ~/Desktop/$fileroot.pdf $fileroot

## Split each sheet into two pages if needed (left-facing and right-facing)
#for i in {2..24};
#do
#  p1=$(($i*2 -4))
#  p2=$(($i*2 -3))
#
#  unpaper --layout double -output-pages 2 \
#    weber_1953-$(printf %02d $i).pbm out$(printf %02d $p1).pbm out$(printf %02d $p2).pbm
#done

for f in $(ls ${fileroot}-*.p?m);
do
  # Convert all others to tif format, then discard
  #convert -density 300 -units PixelsPerInch $f $f.tif && rm $f

  # Use OCR for each image and output a searchable PDF
  tesseract $f $f -l eng -psm 1 -c tessedit_create_pdf=1

done

# Combine all pdfs into a multipage PDF
pdftk ${fileroot}-*.p?m.pdf output ${fileroot}_ocr.pdf

exit;



# Convert set of tifs into one multi-page tif
#tiffcp out??.pbm.tif result.tif && rm -f out??.pbm.tif

# Convert multi-page tif into pdf format
#tiff2pdf result.tif -o result.pdf

