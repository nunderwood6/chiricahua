#adapted from Derek Watkins cheatsheet
# extent in correct format for gdalwarp(xmin,ymin,xmax,ymax)
function ogr_extent() {
	if [ -z "$1" ]; then 
		echo "Missing arguments. Syntax:"
		echo "  ogr_extent <input_vector>"
    	return
	fi
	EXTENT=$(ogrinfo -al -so $1 |\
		grep Extent |\
		sed 's/Extent: //g' |\
		sed 's/(//g' |\
		sed 's/)//g' |\
		sed 's/ - /, /g')
	EXTENT=`echo $EXTENT | awk -F ',' '{print $1 " " $2 " " $3 " " $4}'`
	echo "$EXTENT"
}

echo "Building VRT..."
	gdalbuildvrt  \
	"tmp/a1_merge_dsm.vrt" \
	tmp/dsm/*.tif


# first figure out what we want for a bbox
# clip and convert to tif
# -tr 2 2 / to add target resolution (otherwise will leave native/full res)
# optional reproject here

echo "Clip and make TIF"
gdalwarp -multi \
--config GDAL_CACHEMAX 500 -wm 500 \
-r bilinear \
-te $(ogr_extent data/chiricahua-extent.shp) \
-overwrite \
-of Gtiff \
"tmp/a1_merge_dsm.vrt" "tmp/a2_clipped_dsm.tif" \
-co COMPRESS=DEFLATE -co TILED=YES -co PREDICTOR=2 -co BIGTIFF=YES

# merge with another DEM — borrowed from sponge city work
# combine the two while maintaining the higher resolution of the DSM
# fills no data gaps in DSM
# avoids gdal_fillnodata hallucination issue
# because we use gdal_merge need to activate conda gdal env
# conda env list
# conda activate gdalenv

# # reproject DTM to target proj and bounds
# # clip and convert to tif
# echo "Reproject and clip DTM"
# gdalwarp -multi \
# --config GDAL_CACHEMAX 500 -wm 500 \
# -t_srs "EPSG:7131" \
# -s_srs "EPSG:4269" \
# -r bilinear \
# -te $(ogr_extent data/bbox.shp) \
# -of Gtiff \
# "data/output_USGS10m.tif" "tmp/a3_repro_dtm.tif" \
# -co COMPRESS=DEFLATE -co TILED=YES -co PREDICTOR=2 -co BIGTIFF=YES


# merge the two maintaining the higher res
# gdal_merge
# This utility will automatically mosaic a set of images. 
# All the images must be in the same coordinate system and have a matching number of bands, 
# they may be overlapping, and at different resolutions. 
# In areas of overlap, the last image will be copied over earlier ones. 
# Nodata/transparency values are considered on a band by band level, 
# i.e. a nodata/transparent pixel on one source band will not set a nodata/transparent value on all bands for the target pixel in the resulting raster 
# nor will it overwrite a valid pixel value.
# -ps <pixelsize_x> <pixelsize_y>
# Pixel size to be used for the output file. 
# If not specified the resolution of the first input file will be used.

# gdal_merge -o "tmp/a4_dsm_merged.tif" \
# 			-of Gtiff \
# 			-ot Float32 \
# 			-ps 2 2 \
# 			-co COMPRESS=DEFLATE -co TILED=YES -co PREDICTOR=2 -co BIGTIFF=YES \
# 			"tmp/a3_repro_dtm.tif" "tmp/a2_clipped_dsm.tif"







