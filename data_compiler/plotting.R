setwd("your file path here)
library(tidyverse)
library(ggpubr)
library(dplyr)

BUCS_IF_PMIQ <- read.csv("../compiled_data/BUCS_IF_PMIQ.csv", stringsAsFactors = T)
BUCS_ITotal_PMIQ <- read.csv("../compiled_data/BUCS_ITotal_PMIQ.csv", stringsAsFactors = T)
BUCS_OF_WA50IQ <- read.csv("../compiled_data/BUCS_WA50.csv", stringsAsFactors = T)
BUCS_OF_WA60IQ <- read.csv("../compiled_data/BUCS_WA60.csv", stringsAsFactors = T)
BUCS_OF_WA70IQ <- read.csv("../compiled_data/BUCS_WA70.csv", stringsAsFactors = T)
BUCS_OF_WA900IQ <- read.csv("../compiled_data/BUCS_WA900.csv", stringsAsFactors = T)
BUCS_OF_WA1440_60.50.40.30 <- read.csv("../compiled_data/BUCS_OF_WA1440_60-50-40-30.csv", stringsAsFactors = T)
BUCS_OF_WA1440_70.60.50.30 <- read.csv("../compiled_data/BUCS_OF_WA1440_70-60-50-30.csv", stringsAsFactors = T)
BUCS_OF_WA1440_90.70.50.30 <- read.csv("../compiled_data/BUCS_OF_WA1440_90-70-50-30.csv", stringsAsFactors = T)

{
  #boxplots
  BUCS_IF_PMIQ_counts <- BUCS_IF_PMIQ %>%
    group_by(Style, Sex) %>%
    summarise(n = n())
  
  ggplot(BUCS_IF_PMIQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_IF_PMIQ_counts, aes(x = Style, y = min(BUCS_IF_PMIQ$Tot.) - 0.05 * diff(range(BUCS_IF_PMIQ$Tot.)),
                               label = paste0("n=", n), group = Sex),
            position = position_dodge(width = 0.75),
            size = 4) +
    labs(x= "Style",
         y= "Total Score",
         title= "BUCS Indoor Finals",
         subtitle= "Significance calculated using Wilcoxon test")+
    theme_light()
  
  #boxplots by time and style
  BUCS_IF_PMIQ_counts <- BUCS_IF_PMIQ %>%
    group_by(Style, Sex, Year) %>%
    summarise(n = n())
  
  ggplot(BUCS_IF_PMIQ, aes(x= as.factor(Year), y= Tot., colour= Sex)) +
    geom_boxplot() +
    facet_wrap(~Style) +
    stat_summary(aes(group = Sex),
                 fun = median,
                 geom = "line",
                 size = 0.8) +
    geom_text(data = BUCS_IF_PMIQ_counts, aes(x = as.factor(Year), y = min(BUCS_IF_PMIQ$Tot.) - 0.05 * diff(range(BUCS_IF_PMIQ$Tot.)),
                                              label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Finals")+
    theme_light()
  
  #boxplots by time
  BUCS_IF_PMIQ_counts <- BUCS_IF_PMIQ %>%
    group_by(Sex, Year) %>%
    summarise(n = n())
  
  ggplot(BUCS_IF_PMIQ, aes(x= as.factor(Year), y= Tot., colour= Sex)) +
    geom_boxplot() +
    stat_summary(aes(group = Sex),
                 fun = median,
                 geom = "line",
                 size = 0.8) +
    geom_text(data = BUCS_IF_PMIQ_counts, aes(x = as.factor(Year), y = min(BUCS_IF_PMIQ$Tot.) - 0.05 * diff(range(BUCS_IF_PMIQ$Tot.)),
                                              label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Finals")+
    theme_light()
  
  #distribution
  ggplot(data= BUCS_IF_PMIQ, aes(x= Tot., colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(x= "Total Score",
         y= "Frequency",
         title= "BUCS Indoor Finals")+
    theme_light()
}#BUCS_IF_PMIQ boxplots and distributions
{
  #boxplots by year
  BUCS_ITotal_PMIQ_counts <- BUCS_ITotal_PMIQ %>%
    group_by(Sex, Year) %>%
    summarise(n = n())
  
  ggplot(BUCS_ITotal_PMIQ, aes(x= as.factor(Year), y= Tot., colour= Sex)) +
    geom_boxplot() +
    stat_summary(aes(group = Sex),
                 fun = median,
                 geom = "line",
                 size = 0.8) +
    geom_text(data = BUCS_ITotal_PMIQ_counts, aes(x = as.factor(Year), y = min(BUCS_ITotal_PMIQ$Tot.) - 0.05 * diff(range(BUCS_ITotal_PMIQ$Tot.)),
                                                  label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Qualifiers")+
    theme_light()
  
  #boxplots by year and style
  BUCS_ITotal_PMIQ_counts <- BUCS_ITotal_PMIQ %>%
    group_by(Style, Sex, Year) %>%
    summarise(n = n())
  
  ggplot(BUCS_ITotal_PMIQ, aes(x= as.factor(Year), y= Tot., colour= Sex)) +
    geom_boxplot() +
    facet_wrap(~Style) +
    stat_summary(aes(group = Sex),
                 fun = median,
                 geom = "line",
                 size = 0.8) +
    geom_text(data = BUCS_ITotal_PMIQ_counts, aes(x = as.factor(Year), y = min(BUCS_ITotal_PMIQ$Tot.) - 0.05 * diff(range(BUCS_ITotal_PMIQ$Tot.)),
                                              label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Qualifiers")+
    theme_light()
  
  #boxplots by year, style, and level
  BUCS_ITotal_PMIQ_counts <- BUCS_ITotal_PMIQ %>%
    group_by(Style, Sex, Year, Level) %>%
    summarise(n = n())
  
  ggplot(BUCS_ITotal_PMIQ, aes(x= as.factor(Year), y= Tot., colour= Sex)) +
    geom_boxplot() +
    facet_wrap(~Style*Level) +
    stat_summary(aes(group = Sex),
                 fun = median,
                 geom = "line",
                 size = 0.8) +
    geom_text(data = BUCS_ITotal_PMIQ_counts, aes(x = as.factor(Year), y = min(BUCS_ITotal_PMIQ$Tot.) - 0.05 * diff(range(BUCS_ITotal_PMIQ$Tot.)),
                                                  label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    theme_light()
  
  #boxplot for style by level
  BUCS_ITotal_PMIQ_counts <- BUCS_ITotal_PMIQ %>%
    group_by(Style, Sex, Level) %>%
    summarise(n = n())
  
  ggplot(BUCS_ITotal_PMIQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    facet_wrap(~Level)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Level, Style, Sex)))+
    geom_text(data = BUCS_ITotal_PMIQ_counts, aes(x = Style, y = min(BUCS_ITotal_PMIQ$Tot.) - 0.05 * diff(range(BUCS_ITotal_PMIQ$Tot.)),
                                                  label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Qualifiers",
         subtitle= "Significance calculated by Wilcoxon test")+
    theme_light()
  
  #boxplot for style
  BUCS_ITotal_PMIQ_counts <- BUCS_ITotal_PMIQ %>%
    group_by(Style, Sex) %>%
    summarise(n = n())
  
  ggplot(BUCS_ITotal_PMIQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_ITotal_PMIQ_counts, aes(x = Style, y = min(BUCS_ITotal_PMIQ$Tot.) - 0.05 * diff(range(BUCS_ITotal_PMIQ$Tot.)),
                                                  label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(y= "Total Score",
         x= "Year",
         title= "BUCS Indoor Qualifiers",
         subtitle= "Significance calculated by Wilcoxon test")+
    theme_light()
  
  #frequency distribution by style
  ggplot(data= BUCS_ITotal_PMIQ, aes(x= Tot., colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(y= "Frequency",
         x= "Total Score",
         title= "BUCS Indoor Qualifiers")+
    theme_light()
  
  #frequency distribution by style and level
  ggplot(data= BUCS_ITotal_PMIQ, aes(x= Tot., colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style*Level)+
    labs(y= "Frequency",
         x= "Total Score",
         title= "BUCS Indoor Qualifiers")+
    theme_light()
}#BUCS_ITotal_PMIQ boxplots and distributions
{
  #total score by level
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Level, Style) %>%
    summarise(n = n())

  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    facet_wrap(~Level)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Level, Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$Tot.) - 0.05 * diff(range(BUCS_OF_WA900IQ$Tot.)),
                                                  label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "Total Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #total score
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$Tot.) - 0.05 * diff(range(BUCS_OF_WA900IQ$Tot.)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "Total Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #60m score by level
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Level, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X60.m, colour = Sex))+
    geom_boxplot()+
    facet_wrap(~Level)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Level, Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X60.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X60.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "60m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #60m score
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X60.m, colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X60.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X60.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "60m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #50m score by level
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Level, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X50.m, colour = Sex))+
    geom_boxplot()+
    facet_wrap(~Level)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Level, Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X50.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X50.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "50m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #50m score
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X50.m, colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X50.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X50.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "50m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #40m score by level
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Level, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X40.m, colour = Sex))+
    geom_boxplot()+
    facet_wrap(~Level)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Level, Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X40.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X40.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "40m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #40m score
  BUCS_OF_WA900IQ_counts <- BUCS_OF_WA900IQ %>%
    group_by(Sex, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA900IQ, aes(x= Style, y= X40.m, colour = Sex))+
    geom_boxplot()+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)))+
    geom_text(data = BUCS_OF_WA900IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA900IQ$X40.m) - 0.05 * diff(range(BUCS_OF_WA900IQ$X40.m)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    labs(x= "Style",
         y= "40m Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") +
    theme_light()
  
  #score by distance for styles
  BUCS_OF_900IQ_temp <- BUCS_OF_WA900IQ
  colnames(BUCS_OF_900IQ_temp)[3] <- "60"
  colnames(BUCS_OF_900IQ_temp)[5] <- "50"
  colnames(BUCS_OF_900IQ_temp)[7] <- "40"
  BUCS_WA900_long <- BUCS_OF_900IQ_temp%>%
    select(`60`, `50`, `40`, Sex, Style, Level)%>%
    pivot_longer(
      cols= c(`60`, `50`, `40`),
      names_to= "Variable",
      values_to= "Value"
    )
  ggplot(BUCS_WA900_long, aes(x= Variable, y= Value, colour= Sex))+
    geom_boxplot()+
    facet_wrap(~Style)+
    stat_compare_means(
      method = "wilcox.test", 
      label = "p.signif",
      aes(group = interaction(Style, Sex)),
      label.y.npc= 0.9)+
    ylim(c(0, 350))+
    labs(x= "Distance (m)",
         y= "Score",
         title= "BUCS Outdoors WA900",
         subtitle= "Significance calculated by Wilcoxon test") + 
    theme_light()

  #frequency distributions
  ggplot(data= BUCS_OF_WA900IQ, aes(x= Tot., colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(x= "Total Score",
         y= "Frequency",
         title= "BUCS Outdoors WA900") +
    theme_light()
  
  ggplot(data= BUCS_OF_WA900IQ, aes(x= X60.m, colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(x= "60m Score",
         y= "Frequency",
         title= "BUCS Outdoors WA900") +
    theme_light()
  
  ggplot(data= BUCS_OF_WA900IQ, aes(x= X50.m, colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(x= "50m Score",
         y= "Frequency",
         title= "BUCS Outdoors WA900") +
    theme_light()
  
  ggplot(data= BUCS_OF_WA900IQ, aes(x= X40.m, colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    labs(x= "40m Score",
         y= "Frequency",
         title= "BUCS Outdoors WA900") +
    theme_light()
}#BUCS_OF_WA900IQ boxplots and histograms
{
  #total score
  BUCS_OF_WA70IQ_counts <- BUCS_OF_WA70IQ %>%
    group_by(Sex, Style) %>%
    summarise(n = n())
  
  ggplot(BUCS_OF_WA70IQ, aes(x= Style, y= Tot., colour = Sex))+
    geom_boxplot()+
    geom_text(data = BUCS_OF_WA70IQ_counts, aes(x = as.factor(Style), y = min(BUCS_OF_WA70IQ$Tot.) - 0.05 * diff(range(BUCS_OF_WA70IQ$Tot.)),
                                                 label = paste0("n=", n), group = Sex),
              position = position_dodge(width = 0.9),
              size = 3) +
    theme_light()
  
  #boxplot no open category
  BUCS_OF_WA70IQ_filtered <- BUCS_OF_WA70IQ %>% 
    filter(Sex %in% c("W", "M"))
  
  ggplot(BUCS_OF_WA70IQ_filtered, aes(x = Style, y = Tot., colour = Sex)) +
    geom_boxplot() +
    stat_compare_means(
      method = "wilcox.test",
      label = "p.signif",
      aes(group = interaction(Style, Sex))
    ) +
    geom_text(
      data = BUCS_OF_WA70IQ_counts,
      aes(
        x = as.factor(Style),
        y = min(BUCS_OF_WA70IQ_filtered$Tot.) - 0.05 * diff(range(BUCS_OF_WA70IQ_filtered$Tot.)),
        label = paste0("n=", n),
        group = Sex
      ),
      position = position_dodge(width = 0.9),
      size = 3
    ) +
    theme_light()
  
  #frequency distributions
  ggplot(data= BUCS_OF_WA70IQ, aes(x= Tot., colour = Sex))+
    geom_freqpoly(bins=15)+
    facet_wrap(~Style)+
    theme_light()
}#BUCS_OF_WA70IQ boxplots and histograms

BUCS_ITotal_PMIQ

