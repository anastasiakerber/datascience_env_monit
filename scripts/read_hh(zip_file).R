library(readr)
library(dplyr)

read_hh <- function(zip_file) {

  keep <- c(
    "TIMESTAMP_START", "TIMESTAMP_END", "TA_F", "SW_IN_F", "VPD_F", "P_F",
    "NETRAD", "G_F_MDS", "H_F_MDS", "H_F_MDS_QC", "LE_F_MDS", "LE_F_MDS_QC",
    "NEE_VUT_REF", "NEE_VUT_REF_QC", "GPP_NT_VUT_REF", "RECO_NT_VUT_REF"
  )

  site <- strsplit(basename(zip_file), "_")[[1]][2]

  hh_name <- grep(
    "FLUXMET_HH",
    unzip(zip_file, list = TRUE)$Name,
    value = TRUE)

  unzip(
    zip_file,
    files = hh_name,
    exdir = "data/raw/unzipped",
    overwrite = TRUE)

  hh <- read_csv(
    file.path("data/raw/unzipped", hh_name),
    na = "-9999",
    col_select = any_of(keep),
    col_types = cols(
      TIMESTAMP_START = "c",
      TIMESTAMP_END = "c",
      .default = "d"))

  # Add missing columns
  missing_cols <- setdiff(keep, names(hh))

  for (col in missing_cols) {
    hh[[col]] <- NA}

  # Put columns back in the desired order
  hh <- hh[, keep]

  hh <- hh |>
    mutate(
      site = site,
      time = as.POSIXct(
        TIMESTAMP_START,
        format = "%Y%m%d%H%M",
        tz = "UTC"
      )
    )

  return(hh)}

zip_files <- list.files(
  "data/raw",
  pattern = "\\.zip$",
  full.names = TRUE)

all_hh <- do.call(rbind, lapply(zip_files, read_hh))
