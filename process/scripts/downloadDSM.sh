# first get file names
mapshaper -i data/dsm-tile-index.shp \
		  -each 'console.log(USNG)' \
		  > tmp/file_names.txt

baseUrl="https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/metadata/AZ_CochiseCounty_2020_B20/AZ_CochiseCounty_3_2020/spatial_metadata/contractor_provided/maximum_height_surface_raster/MSHR_"

FILENAME="tmp/file_names.txt"

# Loop through each line of the file
while IFS= read -r line; do
    # Perform operations on each 'line' here
    url="${baseUrl}${line}.tif"
    echo $url

    curl "${url}" -o "tmp/dsm/${line}.tif" ; \

done < "$FILENAME"