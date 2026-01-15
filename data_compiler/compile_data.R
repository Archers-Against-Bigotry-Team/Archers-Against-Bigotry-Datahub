library(tidyverse)
library(readxl)
library(stringr)
library(purrr)

setwd("your file path")#put system file path to compiled_data folder here

category_pattern <- regex("[MWBCRLENO]{2,3}$")
style_pattern <- regex("[LCRB]")
experience_pattern <- regex("[EN]")
sex_pattern <- regex("[MWO]")
year_pattern <- regex("(\\d{4})(?=\\.[^.]+$)")

BUCS_IC_pattern <- regex("IC")
BUCS_IF_pattern <- regex("IF")
BUCS_IN_pattern <- regex("IN")
BUCS_IS_pattern <- regex("IS")
BUCS_WA900_pattern <- regex("WA900")
BUCS_WA1440_pattern <- regex("WA1440")
BUCS_WA70_pattern <- regex("WA70")

remove_cols <- c("Country Code", "Country or State Code", "Country", "&nbsp;", "Società")

filepaths <- list.files("../data")

BUCS_data <- list()
BUCS_IC <- list()
BUCS_IF <- list()
BUCS_IN <- list()
BUCS_IS <- list()
BUCS_WA900 <- list()
BUCS_WA1440 <- list()
BUCS_WA70 <- list()

for (i in seq_along(filepaths))
{
  data_sheets <- excel_sheets(paste0("../data/", filepaths[i]))
  categories <- as.character(rep("", length(data_sheets)))
  year <- str_extract(filepaths[i], year_pattern)
  BUCS_data[[year]] <- list()
  
  BUCS_IC[[year]] <- list()
  BUCS_IF[[year]] <- list()
  BUCS_IN[[year]] <- list()
  BUCS_IS[[year]] <- list()
  BUCS_WA900[[year]] <- list()
  BUCS_WA1440[[year]] <- list()
  BUCS_WA70[[year]] <- list()

  for (j in seq_along(data_sheets))
  {
    sheet <- read_excel(paste0("../data/", filepaths[i]), sheet = j)
    sheet <- sheet[, !(names(sheet) %in% remove_cols)]
    sheet <- sheet[complete.cases(sheet),]
    if ("Atleta" %in% colnames(sheet)) 
    {
      colnames(sheet)[colnames(sheet) == "Atleta"] <- "Athlete"
    }
    sheet$Year <- year
    sheet$Experience <- ""
    categories[j] <- str_extract(data_sheets[j], category_pattern)
    if(str_detect(categories[j], style_pattern))
    {
      sheet$Style <- str_extract(categories[j], style_pattern)
    }
    if(str_detect(categories[j], experience_pattern))
    {
      sheet$Experience <- str_extract(categories[j], experience_pattern)
    }
    if(str_detect(categories[j], sex_pattern))
    {
      sheet$Sex <- str_extract(categories[j], sex_pattern)
    }
    
    BUCS_data[[i]][[data_sheets[j]]] <- sheet
    
    if (str_detect(data_sheets[j], BUCS_IC_pattern))
    {
      BUCS_IC[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_IF_pattern))
    {
      BUCS_IF[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_IN_pattern))
    {
      BUCS_IN[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_IS_pattern))
    {
      BUCS_IS[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_WA900_pattern))
    {
      BUCS_WA900[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_WA1440_pattern))
    {
      BUCS_WA1440[[i]][[data_sheets[j]]] <- sheet
    }
    if (str_detect(data_sheets[j], BUCS_WA70_pattern))
    {
      BUCS_WA70[[i]][[data_sheets[j]]] <- sheet
    }
  }
}

{
for (i in seq_along(BUCS_IS$`2018`))
{
  colnames(BUCS_IS$`2018`[[i]])[3] <- "20y-1"
  colnames(BUCS_IS$`2018`[[i]])[5] <- "20y-2"
}

for (i in seq_along(BUCS_IS$`2019`))
{
  colnames(BUCS_IS$`2019`[[i]])[3] <- "20y-1"
  colnames(BUCS_IS$`2019`[[i]])[5] <- "20y-2"
  colnames(BUCS_IS$`2019`[[i]])[9] <- "Hits"
}

for (i in seq_along(BUCS_IN$`2018`))
{
  colnames(BUCS_IN$`2018`[[i]])[3] <- "20y-1"
  colnames(BUCS_IN$`2018`[[i]])[5] <- "20y-2"
}

for (i in seq_along(BUCS_IN$`2019`))
{
  colnames(BUCS_IN$`2019`[[i]])[3] <- "20y-1"
  colnames(BUCS_IN$`2019`[[i]])[5] <- "20y-2"
}

for (i in seq_along(BUCS_IN$`2019`))
{
  colnames(BUCS_IN$`2019`[[i]])[3] <- "20y-1"
  colnames(BUCS_IN$`2019`[[i]])[5] <- "20y-2"
  colnames(BUCS_IN$`2019`[[i]])[9] <- "Hits"
}

BUCS_IS_total <- map_dfr(BUCS_IS, ~ bind_rows(.x, .id = "Sheet"), .id = "Year")
BUCS_IC_total <- map_dfr(BUCS_IC, ~ bind_rows(.x, .id = "Sheet"), .id = "Year")
BUCS_IN_total <- map_dfr(BUCS_IN, ~ bind_rows(.x, .id = "Sheet"), .id = "Year")

BUCS_IQ_total <- rbind(BUCS_IS_total,
                       BUCS_IC_total,
                       BUCS_IN_total)
BUCS_IF_total <- map_dfr(BUCS_IF, ~ bind_rows(.x, .id = "Sheet"), .id = "Year")

write.csv(BUCS_IQ_total,"../compiled_data/BUCS_ITotal_PMIQ.csv", row.names = F)
write.csv(BUCS_IF_total,"../compiled_data/BUCS_IF_PMIQ.csv", row.names = F)
}#BUCS indoor finals and qualifiers

{
BUCS_WA70_flat <- unlist(BUCS_WA70, recursive = FALSE)

col_hash <- sapply(BUCS_WA70_flat, function(df) paste(sort(names(df)), collapse = "_"))

dfs_grouped <- split(BUCS_WA70_flat, col_hash)

merged_dfs <- map(dfs_grouped, ~ bind_rows(.x))

BUCS_WA50 <- rbind(merged_dfs[[1]], merged_dfs[[4]])
BUCS_WA60 <- merged_dfs[[2]]
BUCS_WA70 <- rbind(merged_dfs[[3]], merged_dfs[[5]])

write.csv(BUCS_WA50, "../compiled_data/BUCS_WA50.csv", row.names = F)
write.csv(BUCS_WA60, "../compiled_data/BUCS_WA60.csv", row.names = F)
write.csv(BUCS_WA70, "../compiled_data/BUCS_WA70.csv", row.names = F)
}#BUCS WA50,60,70

{
BUCS_WA900_flat <- unlist(BUCS_WA900, recursive = FALSE)

col_hash <- sapply(BUCS_WA900_flat, function(df) paste(sort(names(df)), collapse = "_"))

dfs_grouped <- split(BUCS_WA900_flat, col_hash)

merged_dfs <- map(dfs_grouped, ~ bind_rows(.x))

BUCS_WA900 <- merged_dfs[[1]]

write.csv(BUCS_WA900, "../compiled_data/BUCS_WA900.csv", row.names = F)
}#BUCS WA900

{
BUCS_WA1440_flat <- unlist(BUCS_WA1440, recursive = FALSE)

col_hash <- sapply(BUCS_WA1440_flat, function(df) paste(sort(names(df)), collapse = "_"))

dfs_grouped <- split(BUCS_WA1440_flat, col_hash)

merged_dfs <- map(dfs_grouped, ~ bind_rows(.x))

colnames(merged_dfs[[3]]) <- colnames(merged_dfs[[6]])
colnames(merged_dfs[[1]]) <- colnames(merged_dfs[[6]])
colnames(merged_dfs[[2]]) <- colnames(merged_dfs[[7]])

BUCS_OF_WA1440_90.70.50.30 <- rbind(merged_dfs[[1]], merged_dfs[[3]], merged_dfs[[6]])
BUCS_OF_WA1440_70.60.50.30 <- rbind(merged_dfs[[2]], merged_dfs[[7]])
BUCS_OF_WA1440_60.50.40.30 <- merged_dfs[[5]]

colnames(BUCS_OF_WA1440_90.70.50.30) <- colnames(BUCS_OF_WA1440_90.70.50.30)[c(1, 2, 4, 3, 6, 5, 8, 7, 10, 9, 11, 12, 13, 14, 15, 16, 17)]
colnames(BUCS_OF_WA1440_70.60.50.30) <- colnames(BUCS_OF_WA1440_70.60.50.30)[c(1, 2, 4, 3, 6, 5, 8, 7, 10, 9, 11, 12, 13, 14, 15, 16, 17)]
colnames(BUCS_OF_WA1440_60.50.40.30) <- colnames(BUCS_OF_WA1440_60.50.40.30)[c(1, 2, 4, 3, 6, 5, 8, 7, 10, 9, 11, 12, 13, 14, 15, 16, 17)]
write.csv(BUCS_OF_WA1440_90.70.50.30, "../compiled_data/BUCS_OF_WA1440_90-70-50-30.csv", row.names = F)
write.csv(BUCS_OF_WA1440_70.60.50.30, "../compiled_data/BUCS_OF_WA1440_70-60-50-30.csv", row.names = F)
write.csv(BUCS_OF_WA1440_60.50.40.30, "../compiled_data/BUCS_OF_WA1440_60-50-40-30.csv", row.names = F)
}#BUCS WA1440

rm(list=ls())#unload all objects
