# Price Optimization with Laptop Sales Data  
Applied Marketing Analytics Project | 
Date: 20 April 2023

---

## Overview

Pricing decisions directly influence demand, revenue, and market positioning. Despite this, prices are often set using heuristics, competitor benchmarks, or intuition rather than data driven demand modeling. As a result, organizations may underprice high value products or overprice price sensitive segments.

This project presents a data driven price optimization analysis using historical laptop sales data. A regression based demand model is used to estimate price sensitivity, segment products by price tier, and identify sales maximizing prices. The impact of optimized pricing decisions is then evaluated and visualized.

---

## Business Problem

A retailer sells laptops across multiple brands, models, and technical specifications. Management must decide how to price products in a way that balances demand and revenue across different market segments.

Without a structured analytical approach, pricing decisions can lead to:
- Underpricing premium products  
- Overpricing price sensitive products  
- Inconsistent pricing across segments  
- Suboptimal revenue and sales outcomes  

The core challenge is determining prices that reflect both customer price sensitivity and product characteristics.

---

## Objective

The objectives of this project are to:
- Prepare and clean historical laptop sales data  
- Segment products into low, medium, and high price tiers  
- Estimate demand using a multivariate regression model  
- Identify sales maximizing prices by product and segment  
- Quantify the impact of optimized pricing on total sales  
- Build a clean, reproducible analytics workflow  

---

## Data Description

The dataset contains historical laptop sales data with the following variables:

| Variable | Description |
|---|---|
| Brand | Laptop brand |
| Model | Laptop model |
| Price | Selling price |
| Sales | Units sold |
| RAM | Installed memory |
| Processor.Speed | CPU speed |
| price_segment | Derived price tier (Low, Medium, High) |

Each row represents a product level observation with associated pricing, specifications, and sales outcomes.

---

## Methodology

### Data Preparation

The raw dataset is cleaned by converting variables to appropriate numeric formats, removing invalid or missing observations, and segmenting products into price tiers using terciles. A prepared dataset is saved for downstream modeling and analysis.

### Demand Modeling and Price Optimization

A linear regression model is trained to estimate demand as a function of:
- Price  
- RAM  
- Processor speed  

Using the fitted model, candidate prices are evaluated over a defined range and the price that maximizes predicted sales is selected for each product. Optimized prices are applied back to the dataset to compare sales outcomes before and after optimization.

---

## Results

Key findings:
- Price sensitivity differs significantly across price segments  
- Optimal prices vary meaningfully between low, medium, and high tiers  
- Regression based optimization produces different conclusions than heuristic pricing  
- Optimized prices can materially change expected sales outcomes  

---

## Limitations

- The analysis is observational and not causal  
- Costs, margins, and profitability are not included  
- Demand is assumed to be linear in price  
- Competitive dynamics are not modeled  

Results should be interpreted as directional guidance rather than final pricing policy.

---

## Project Structure

price-optimization-laptop-sales/  
├── README.md  
├── data/  
│   └── laptop_sales.csv  
├── src/  
│   ├── data_preparation.R  
│   ├── price_optimization.R  
│   └── visualization.R  
├── figures/  
│   ├── sales_impact_by_segment.png  
│   └── avg_price_vs_sales.png  
└── results/  
    ├── laptop_sales_segmented.rds  
    ├── optimized_laptop_sales.rds  
    ├── total_sales_before.rds  
    └── total_sales_after.rds  

---

## Reproducibility

From the project root directory, run:

```r
source("src/data_preparation.R")
source("src/price_optimization.R")
source("src/visualization.R")
```
---
## Author

Abdoulaye Diop
