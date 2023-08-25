
# BIDS-TP Hackathon 2023

## Setup R environment

Install the following R packages using `install.packages()`:

   1) tidyverse
   2) arrow
   3) spatstat
   4) spatstat.explore
   5) spatstat.model
   6) sf
   7) mgcv


## Description of data

[drive link for the data](https://drive.google.com/drive/folders/1aC2mSJEQbKR0IL0fUK0ryCAZuuFcMzqU)

#### data/TS2PL1_Cell_MasterDataTable.parquet
703 morphological features for 1,698,930 huh-7 hepatocyte cells. Each
cell is contained in one of 9 fields of view in one of 384 wells.

Each well was either uninfected, or infected such that at the end of
the assay at 48 hours it had been infected for between 8 and 48 hours.

  Condition    Number of cells
  18 hours     300276
  24 hours     248414
  30 hours     242315
  36 hours     213150
  48 hours     149378
  8 hours      307062
  Uninfected   238335

Feature were generated using CellProfiler after fixing and staining cells with four different dyes (Hoe: hoechst, stains nuclei; ConA: Concanavalin A, stains membranes; Spike: stains SARS-CoV-2 Spike protein; and NP: stains SARS-CoV-2 N-protein) and then imaging with a confocal microscope. Features are named based on the

   <object>_<feature_type>_<measurement>_<stain>

For instance

   Cells_Intensity_MeanIntensityEdge_Spike

is the meain edge intensity of the Spike stain in the Cells objects

#### data/cell_clusters.parquet
Modularity based clustering of cells based on cellular phenotype into 239 clusters (median cluster size 7161).

