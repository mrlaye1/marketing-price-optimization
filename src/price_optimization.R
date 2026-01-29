# ============================================================
# Project: Price Optimization
# File: price_optimization.R
# Purpose: Demand modeling and price optimization
# Author: Abdoulaye Diop
# ============================================================

message("Starting price optimization workflow...")

# =========================
# 1. Load Required Packages
# =========================

library(dplyr)
message(" 1.Required packages loaded.")

# =========================
# 2. Load Prepared Data
# =========================
# Expected file:
# results/prepared_laptop_sales.rds

data_path <- file.path("results", "prepared_laptop_sales.rds")

if (!file.exists(data_path)) {
  stop("Prepared data not found: results/prepared_laptop_sales.rds")
}

laptop_sales_segmented <- readRDS(data_path)
message(" 2.Prepared dataset loaded successfully.")

# =========================
# 3. Basic Validation
# =========================

if (nrow(laptop_sales_segmented) < 10) {
  stop("Not enough observations to run price optimization.")
}

# =========================
# 4. Adaptive Demand Model
# =========================
# Build model formula based on available data
# This prevents singular matrix errors

model_formula <- Sales ~ Price

if (sum(!is.na(laptop_sales_segmented$RAM)) > 10) {
  model_formula <- update(model_formula, . ~ . + RAM)
}

if (sum(!is.na(laptop_sales_segmented$Processor.Speed)) > 10) {
  model_formula <- update(model_formula, . ~ . + Processor.Speed)
}

lm_model <- lm(
  model_formula,
  data = laptop_sales_segmented,
  na.action = na.exclude
)

message(" 3.Demand model fitted successfully.")
message("   Final model formula:")
print(model_formula)

# =========================
# 5. Prediction Functions
# =========================

predict_sales <- function(model, price, ram, processor_speed) {
  
  new_data <- data.frame(
    Price = price,
    RAM = ram,
    Processor.Speed = processor_speed
  )
  
  predict(model, newdata = new_data)
}

optimize_price <- function(model, ram, processor_speed, price_range) {
  
  prices <- seq(price_range[1], price_range[2], length.out = 100)
  
  predicted_sales <- sapply(
    prices,
    predict_sales,
    model = model,
    ram = ram,
    processor_speed = processor_speed
  )
  
  prices[which.max(predicted_sales)]
}

message(" 4.Prediction and optimization functions defined.")

# =========================
# 6. Optimize Prices by Segment
# =========================

optimize_segment <- function(data_segment) {
  
  price_range <- range(data_segment$Price, na.rm = TRUE)
  
  data_segment %>%
    group_by(Brand, Model) %>%
    summarize(
      optimal_price = optimize_price(
        lm_model,
        RAM[1],
        Processor.Speed[1],
        price_range
      ),
      .groups = "drop"
    )
}

low_segment <- filter(laptop_sales_segmented, price_segment == "Low")
medium_segment <- filter(laptop_sales_segmented, price_segment == "Medium")
high_segment <- filter(laptop_sales_segmented, price_segment == "High")

message(" 5.Data split into price segments.")

optimal_low <- optimize_segment(low_segment)
optimal_medium <- optimize_segment(medium_segment)
optimal_high <- optimize_segment(high_segment)

message(" 6.Optimal prices computed for all segments.")

# =========================
# 7. Apply Optimized Prices
# =========================

optimal_prices <- bind_rows(
  optimal_low,
  optimal_medium,
  optimal_high
)

optimized_laptop_sales <- laptop_sales_segmented %>%
  left_join(optimal_prices, by = c("Brand", "Model")) %>%
  mutate(
    Optimized_Price = ifelse(is.na(optimal_price), Price, optimal_price)
  )

message(" 7.Optimized prices applied to dataset.")

# =========================
# 8. Sales Impact Analysis
# =========================

total_sales_before <- optimized_laptop_sales %>%
  group_by(price_segment) %>%
  summarize(
    total_sales = sum(Sales),
    .groups = "drop"
  )

total_sales_after <- optimized_laptop_sales %>%
  group_by(price_segment) %>%
  summarize(
    total_sales = sum(
      predict(
        lm_model,
        newdata = data.frame(
          Price = Optimized_Price,
          RAM = RAM,
          Processor.Speed = Processor.Speed
        )
      )
    ),
    .groups = "drop"
  )

message(" 8.Sales impact before and after optimization calculated.")

# =========================
# 9. Save Outputs
# =========================

if (!dir.exists("results")) {
  dir.create("results")
}

saveRDS(
  optimized_laptop_sales,
  file = file.path("results", "optimized_laptop_sales.rds")
)

saveRDS(
  total_sales_before,
  file = file.path("results", "total_sales_before.rds")
)

saveRDS(
  total_sales_after,
  file = file.path("results", "total_sales_after.rds")
)
message("")
message("All outputs saved to results/ directory.")
message("Price optimization workflow completed successfully.")
