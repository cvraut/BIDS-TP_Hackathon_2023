
library(tidyverse)
library(arrow)

source("scripts/compute_spatial_features.R")

cell_features_TS2PL1 <- arrow::read_parquet(
    file = "data/TS2PL1_Cell_MasterDataTable.parquet") |>
  compute_well_coordinates()

cell_feature_columns <- readr::read_tsv(
  "data/cell_feature_columns_TS_202008.tsv",
  show_col_types = FALSE)

cell_metadata_columns <- readr::read_tsv(
  "data/cell_metadata_columns_TS_202008.tsv",
  show_col_types = FALSE)

# for testing make this a smaller subset
cell_features_rel <- cell_features_TS2PL1 |>
  dplyr::filter(time_point == "Uninfected")
rm(cell_features_TS2PL1)
gc()

# generate neighbor graph
neighbor_graph <- cell_features_TS2PL1 |>
  dplyr::filter(time_point == "Uninfected") |>
  compute_neighbor_graph_by_well(verbose = TRUE)


spatial_correlation <- cell_feature_columns |>
  dplyr::rowwise() |>
  dplyr::do({
    cell_feature_column <- .
    cat("Cell feature: ", cell_feature_column$feature, "\n", sep = "")
    neighbor_graph |>
      dplyr::left_join(
        cell_features_rel |>
          dplyr::select(
            plate_id,
            row,
            column,
            cell1_well_index = well_index,
            feature_value1 = tidyselect::any_of(cell_feature_column$feature)),
        by = c("plate_id", "row", "column", "cell1_well_index")) |>
      dplyr::left_join(
        cell_features_rel |>
          dplyr::select(
            plate_id,
            row,
            column,
            cell2_well_index = well_index,
            feature_value2 = tidyselect::any_of(cell_feature_column$feature)),
        by = c("plate_id", "row", "column", "cell2_well_index")) |>
      dplyr::group_by(plate_id, row, column) |>
      dplyr::summarize(
        feature_name = cell_feature_column$feature,
        rank_correlation = cor(feature_value1, feature_value2, method="spearman"),
	.groups = "drop")
  })

spatial_correlation_summary <- spatial_correlation |>
  dplyr::group_by(feature_name) |>
  dplyr::summarize(
    rank_correlation_mean = mean(rank_correlation),
    rank_correlation_sd = sd(rank_correlation)) |>
  dplyr::ungroup() |>
  dplyr::arrange(desc(rank_correlation_mean))


# plot an example of a high neighbor correlation feature
feature <- "Nuclei_Intensity_MeanIntensityEdge_Hoe"
plot_data <- neighbor_graph |>
  dplyr::left_join(
    cell_features_rel |>
      dplyr::select(
        plate_id,
        row,
        column,
        cell1_well_index = well_index,
        feature_value1 = tidyselect::any_of(feature)),
    by = c("plate_id", "row", "column", "cell1_well_index")) |>
  dplyr::left_join(
    cell_features_rel |>
      dplyr::select(
        plate_id,
        row,
        column,
        cell2_well_index = well_index,
        feature_value2 = tidyselect::any_of(feature)),
    by = c("plate_id", "row", "column", "cell2_well_index"))

plot <- ggplot2::ggplot(
  data = plot_data |>
    dplyr::ungroup() |>
    dplyr::filter(row == 1, column == 18)) +
  ggplot2::theme_bw() +
  ggplot2::geom_point(
    mapping = ggplot2::aes(
      x = feature_value1,
      y = feature_value2),
    size = .5,
    alpha = .5,
    shape = 16) +
  ggplot2::coord_fixed() +
  ggplot2::ggtitle(paste0("Neighbor correlation: ", feature)) +
  ggplot2::scale_x_continuous(paste0("Query Cell Feature Value")) +
  ggplot2::scale_y_continuous(paste0("Neighbor Cell Feature Value"))

ggplot2::ggsave(
  filename = paste0("product/correlation_uninfected_row1_column18_", feature, ".pdf"),
  plot = plot,
  width = 7,
  height = 7,
  useDingbats = FALSE)

