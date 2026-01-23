library(tidyverse)
library(readxl)
library(stringr)
library(purrr)
library(dplyr)

setwd("your file path")#set your working directory here

year_pattern <- regex("(\\d{4})(?=\\.[^.]+$)")
sex_pattern <- regex("[MWO]")
style_pattern <- regex("[LCRB]")
over50_pattern <- regex("50")

remove_cols <- c("Country Code", "Country or State Code", "Country", "&nbsp;", "Società")

filepaths <- list.files("../indoor_nationals_data")
filepaths <- filepaths[!str_detect(filepaths, "IQIS")]
filepaths <- filepaths[!str_detect(filepaths, "HN")]
nationals_data <- list()

for (i in seq_along(filepaths))
{
  data_sheets <- excel_sheets(paste0("../indoor_nationals_data/", filepaths[i]))
  year <- str_extract(filepaths[i], year_pattern)
  nationals_data[[year]] <- list()
  
  for (j in seq_along(data_sheets))
  {
    sheet <- read_excel(paste0("../indoor_nationals_data/", filepaths[i]), sheet = j)
    sheet <- sheet[, -1]
    sheet <- sheet[, colMeans(is.na(sheet)) <= 0.5]
    sheet <- sheet[, !(names(sheet) %in% remove_cols)]
    sheet$Sex <- "O"
    sheet$Year <- year
    sheet$`over 50?` <- "N"
    sheet$Pos. <- as.character(sheet$Pos.)
    if(str_detect(data_sheets[j], style_pattern))
    {
      sheet$Style <- str_extract(data_sheets[j], style_pattern)
    }
    if(str_detect(data_sheets[j], over50_pattern))
    {
      sheet$`over 50?` <- "Y"
    }
    if(str_detect(data_sheets[j], sex_pattern))
    {
      sheet$Sex <- str_extract(data_sheets[j], sex_pattern)
    }
    nationals_data[[i]][[data_sheets[j]]] <- sheet
  }
    
}

nationals_indoors_total <- map_dfr(nationals_data, ~ bind_rows(.x, .id = "Sheet"), .id = "Year")

write.csv(nationals_indoors_total,"../compiled_data/national_indoors.csv", row.names = F)