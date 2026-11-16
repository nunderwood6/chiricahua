
nonGeoRaster="renders/higher-res_11-16.jpg"

# Example: Pad image to 4096x4096 anchored at the top-left
magick $nonGeoRaster \
	 -background none \
	 -extent 8192x8192 \
	 tmp/padded.png

# assign to mercator and make it span the whole world
gdal_translate -of GTiff \
	-a_srs EPSG:3857 \
	-a_ullr -20037508.342789244 20037508.342789244 20037508.342789244 -20037508.342789244 \
	tmp/padded.png \
	tmp/chiricahua_mercator.tif

# convert it to pmtiles
geotiff2pmtiles \
--format webp \
--tile-size 1024 \
--type overlay \
tmp/chiricahua_mercator.tif \
tmp/chiricahua.pmtiles








# # assign mercator projection to image
# gdal_translate -a_srs EPSG:3857 \
# 		-a_ullr 0 2.25 3.75 0 \
# 		$nonGeoRaster \
# 		tmp/chiricahua_mercator.tif

# # slice the image into an XYZ directory structure (e.g., zooms 0 through 5)
# gdal2tiles.py --xyz \
# 			--zoom=0-5 \
# 			-p raster \
# 			tmp/chiricahua_mercator.tif \
# 			tmp/tiles

# # convert tiles to MBTiles
# mb-util --scheme=xyz \
# 		tmp/tiles \
# 		tmp/chiricahua.mbtiles

# # convert to pmtiles
# pmtiles convert tmp/chiricahua.mbtiles \
# 		web-assets/chiricahua.pmtiles


