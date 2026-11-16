
dsm="tmp/a2_clipped_dsm.tif"


#get min/max values
min=`gdalinfo -mm $dsm | sed -ne 's/.*Computed Min\/Max=//p'| tr -d ' ' | cut -d "," -f 1 | cut -d . -f 1`
max=`gdalinfo -mm $dsm | sed -ne 's/.*Computed Min\/Max=//p'| tr -d ' ' | cut -d "," -f 2 | cut -d . -f 1`

#rescale and output as 16 bit unsigned TIF
echo "Rescaling raster values..."
gdal_translate -scale $min $max 0 255 \
 $dsm tmp/a3_stretched_dsm.png