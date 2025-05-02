#!/bin/bash

cd /Users/peterdresslar/Workspace/GOL-1d-nl/data

# Create a backup directory
mkdir -p backup
cp *.csv backup/

# Rename the files
mv "1d-2d-Life 1D2DLifeDensityWideSweep (wrapping OFF)-table.csv" "1d-2d-Life-OFF.csv"
mv "1d-2d-Life 1D2DLifeDensityWideSweep (wrapping ON)-table.csv" "1d-2d-Life-ON.csv"
mv "1d-Life 1DLifeDensityWideSweep (wrapping OFF)-table.csv" "1d-Life-OFF.csv"
mv "1d-Life 1DLifeDensityWideSweep (wrapping ON)-table.csv" "1d-Life-ON.csv"
mv "Life 2DLifeDensityWideSweep (wrapping OFF)-table.csv" "2d-Life-OFF.csv"
mv "Life 2DLifeDensityWideSweep (wrapping ON)-table.csv" "2d-Life-ON.csv"

echo "Files renamed successfully. Original files backed up in ./backup/"