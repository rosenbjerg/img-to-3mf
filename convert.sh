#!/bin/bash

# Usage: ./convert_files.sh <input_glob> [height]

# Get height if provided, otherwise set to default
if [ $# -eq 2 ]; then
  height="$2"
else
  height="5"
fi

function svg_to_3mf () {
    # Convert svg files to 3mf format using OpenSCAD
    local input_file="$1"
    tmp_scad="${input_file%.*}.scad"
    echo "linear_extrude(height = $height) import(\"${input_file%.*}.svg\");" > $tmp_scad
    openscad -o "${input_file%.*}.3mf" $tmp_scad

    # Delete the intermediate files
    rm $tmp_scad
}

for file in $1; do
    echo ""
    echo "Converting $file -> ${file%.*}.svg with height of $height and base height of $base_height"
    if [[ $file == *.jpg || $file == *.jpeg || $file == *.png || $file == *.webp ]]; then
        # Convert jpeg and png files to pnm format
        convert -flop "$file" -fx 'a==0 ? white : u' "${file%.*}.pnm"

        # Convert pnm files to svg format using potrace
        potrace "${file%.*}.pnm" -s -o "${file%.*}.svg"

        # Convert svg files to 3mf format using OpenSCAD
        svg_to_3mf "$file"

        rm "${file%.*}.pnm" "${file%.*}.svg"
    elif [[ $file == *.svg ]]; then
        svg_to_3mf "$file"
    fi
    echo ""
done