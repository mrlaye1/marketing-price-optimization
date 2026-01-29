# ============================================================
# Project: Price Optimization
# File: visualization.R
# Purpose: Visualize price optimization results
# Author: Abdoulaye Diop
# ============================================================

message("Starting visualization workflow...")

# =========================
# Load Required Packages
# =========================

library(dplyr)
library(ggplot2)

message(" 1.Required packages loaded.")

# =========================
# Load Results
# =========================

optimized_path <- file.path("results", "optimized_laptop_sales.rds")
before_path <- file.path("results", "total_sales_before.rds")
after_path <- file.path("results", "total_sales_after.rds")

if (!file.exists(optimized_path) ||
    !file.exists(before_path) ||
    !file.exists(after_path)) {
  stop("One or more required result files are missing in the results directory.")
}

optimized_laptop_sales <- readRDS(optimized_path)
total_sales_before <- readRDS(before_path)
total_sales_after <- readRDS(after_path)

message(" 2.Result datasets loaded successfully.")

# =========================
# Ensure Figures Directory
# =========================

if (!dir.exists("figures")) {
  dir.create("figures")
  message("Figures directory created.")
}

# =========================
# Bar Plot: Sales Impact
# =========================

message(" 3.Preparing sales impact bar plot.")

plot_data <- bind_rows(
  mutate(total_sales_before, optimization = "Before Optimization"),
  mutate(total_sales_after, optimization = "After Optimization")
)

sales_impact_plot <- ggplot(
  plot_data,
  aes(x = price_segment, y = total_sales, fill = optimization)
) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Impact of Optimized Prices on Sales",
    x = "Price Segment",
    y = "Total Sales"
  ) +
  theme_minimal()

print(sales_impact_plot)

ggsave(
  filename = file.path("figures", "sales_impact_by_segment.png"),
  plot = sales_impact_plot,
  width = 8,
  height = 5
)

message(" 4.Sales impact bar plot displayed and saved to figures.")

# =========================
# Average Price vs Sales
# =========================

message(" 5.Calculating average price and sales metrics.")

avg_before <- optimized_laptop_sales %>%
  group_by(price_segment) %>%
  summarize(
    avg_price = mean(Price),
    avg_sales = mean(Sales),
    .groups = "drop"
  ) %>%
  mutate(optimization = "Before Optimization")

avg_after <- optimized_laptop_sales %>%
  group_by(price_segment) %>%
  summarize(
    avg_price = mean(Optimized_Price),
    avg_sales = mean(Sales),
    .groups = "drop"
  ) %>%
  mutate(optimization = "After Optimization")

avg_data <- bind_rows(avg_before, avg_after)

message(" 6.Preparing average price vs sales scatter plot.")

avg_price_sales_plot <- ggplot(
  avg_data,
  aes(
    x = avg_price,
    y = avg_sales,
    color = price_segment,
    shape = optimization
  )
) +
  geom_point(size = 4) +
  labs(
    title = "Average Price and Sales Comparison",
    x = "Average Price",
    y = "Average Sales"
  ) +
  theme_bw()

print(avg_price_sales_plot)

ggsave(
  filename = file.path("figures", "avg_price_vs_sales.png"),
  plot = avg_price_sales_plot,
  width = 8,
  height = 5
)

message(" 7.Average price vs sales plot displayed and saved to figures.")

message("")
message("Visualization workflow completed successfully.")
