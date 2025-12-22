# =============================================================================
# Author: Nicole Boumans
# Program: Master of Science in Health Care Informatics (MSHCI)
# Date: 2025-12-19
#
# Script: COPD_Prevalence.R
# Project: US_COPD_Choropleth
#
# Purpose:
#   This script loads cleaned state-level COPD prevalence data from the CDC
#   BRFSS survey, merges it with U.S. state boundary spatial data, and produces
#   a choropleth map visualizing geographic variation in COPD prevalence among
#   adults (18+) in the United States.
#
# Data Source:
#   Centers for Disease Control and Prevention (CDC)
#   Behavioral Risk Factor Surveillance System (BRFSS) Prevalence & Trends
#   https://www.cdc.gov/brfss/brfssprevalence/index.html
#
# Inputs:
#   data/copd_state_prevalence.csv  - Cleaned state-level prevalence data (%)
#
# Outputs:
#   figures/copd_map.png            - Choropleth map figure
#
# Notes:
#   - State names are standardized to title case prior to merging.
#   - A spelling inconsistency in the raw source table was corrected during
#     data cleaning before analysis.
#   - File paths are handled using the 'here' package for reproducibility.
#
# =============================================================================
#
#
# -----------------------------
# 1. Load Packages
# -----------------------------
library(tidyverse)
library(ggplot2)
library(sf)            # for spatial data
library(here)          # reproducible file paths
library(maps)# U.S. state boundaries

# -----------------------------
# 2. Load COPD Data
# -----------------------------
# https://www.cdc.gov/brfss/brfssprevalence/index.html
copd_data <- read_csv(here("data", "copd_state_prevalence.csv")) %>%
  mutate(state = str_to_title(state))  # standardize state names

# -----------------------------
# 3. Load U.S. State Boundaries
# -----------------------------
us_states <- st_as_sf(map("state", plot = FALSE, fill = TRUE)) %>%
  mutate(name = str_to_title(ID)) # create a name column

# -----------------------------
# 4. Merge COPD Data with Map
# -----------------------------
map_data <- us_states %>%
  left_join(copd_data, by = c("name" = "state"))

# Check merge
glimpse(map_data)
summary(map_data$prevalence) # optional: see min/max values

# -----------------------------
# 5. Create Choropleth Map
# -----------------------------
ggplot(map_data) +
  geom_sf(aes(fill = prevalence), color = "white") +
  scale_fill_continuous(low = "#EAECEE", high = "#17202A", na.value = "grey80", name = "Prevalence(%)") +
  
  labs(
    title = "State-Level Prevalence of COPD (Adults, 18+)",
    subtitle = "Data source: BRFSS Prevalence & Trends Data, 2024",
    caption = "Figure 1: State-level prevalence of COPD across the U.S."
  ) +
  theme_minimal() +
  theme(
    plot.title   = element_text(size = 16, face = "bold"),
    plot.subtitle= element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 0),
    axis.title   = element_blank(),
    axis.text    = element_blank(),
    axis.ticks   = element_blank(),
    panel.grid    = element_blank()
  ) +
  coord_sf()

# -----------------------------
# 6. Save Figure
# -----------------------------
ggsave(here("figures/copd_map.png"), width = 10, height = 7)
