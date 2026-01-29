# ------------------------------------------------------------
# Project: Price Optimization
# File: data_preparation.R
# Purpose: Load, clean, and prepare laptop sales data
# Author: Abdoulaye Diop
# ------------------------------------------------------------

# =========================
# 1. Load Required Packages
# =========================

required_packages <- c("dplyr")

invisible(lapply(required_packages, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(paste("Missing package:", pkg))
  }
  library(pkg, character.only = TRUE)
}))

# =========================
# 2. Read Laptop Sales Data
# =========================
# Expected location:
# project_root/data/laptop_sales.csv

data_path <- file.path("data", "laptop_sales.csv")

if (!file.exists(data_path)) {
  stop("Data file not found: data/laptop_sales.csv")
}

laptop_sales <- read.csv(data_path, stringsAsFactors = FALSE)

# =========================
# 3. Data Cleaning
# =========================

laptop_sales <- laptop_sales %>%
  mutate(
    Price = suppressWarnings(as.numeric(Price)),
    Sales = suppressWarnings(as.numeric(Sales)),
    RAM = suppressWarnings(as.numeric(gsub("[^0-9]", "", RAM))),
    Processor.Speed = suppressWarnings(as.numeric(Processor.Speed))
  )

# Keep only rows required for modeling
laptop_sales <- laptop_sales %>%
  filter(
    !is.na(Price),
    !is.na(Sales)
  )

# =========================
# 4. Create Robust Price Segments
# =========================

price_breaks <- quantile(
  laptop_sales$Price,
  probs = c(0, 0.33, 0.67, 1),
  na.rm = TRUE
)

price_breaks <- unique(price_breaks)

laptop_sales <- laptop_sales %>%
  mutate(
    price_segment = cut(
      Price,
      breaks = price_breaks,
      include.lowest = TRUE,
      labels = c("Low", "Medium", "High")[seq_len(length(price_breaks) - 1)]
    )
  )

# =========================
# 5. Final Validation
# =========================

if (nrow(laptop_sales) < 10) {
  stop("Not enough valid observations after data preparation")
}

# =========================
# 6. Save Prepared Data
# =========================

if (!dir.exists("results")) {
  dir.create("results")
}

saveRDS(
  laptop_sales,
  file.path("results", "prepared_laptop_sales.rds")
)

message("Data preparation completed successfully.")
