#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is one argument, required: if not, return an error
if (length(args)!=1) {
  stop("Provide the location of the output files", call.=FALSE)
}

# "../output" in C++
# "output/" in Python
setwd(args[1])

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, gifski, gganimate)
library(tidyverse)
library(gganimate)

#library(fs)
#library(patchwork)
#library(rlang)

#==== Import vigilance data ====
# Below is a small commented out script to create fake data
# vigilance <- runif(n=100,min=0,max=1)
# time <- seq(1,length(vigilance))
# vigilance_data <- vigilance %>% 
#   as_tibble() %>%
#   rename(vigilance = value) %>%
#   add_column(generations = time)

vigilance <- read_csv("vigilance_out.txt", col_names = FALSE, col_types = "id")

vigilance_data <- vigilance %>% 
  rename(generations = X1, vigilance = X2)

#==== Plot Vigilance ====

vPlot <- vigilance_data %>%
  ggplot(aes(generations, vigilance)) +
  geom_line() +
  ylim(0,1) +
  theme_minimal() +
  transition_reveal(generations)

anim_save("vigilance_out.gif", vPlot)

#==== Import ecosystem data ====
resources <- read_csv("resources_out.txt", col_names = FALSE) 
resource_data <- resources %>%
  rename(time = X1, x = X2, y = X3, resource = X4)

# rPlot <- resource_data %>%
#   ggplot(aes(x, y)) +
#   geom_tile(aes(fill = resource)) +
#   theme_classic() +
#   scale_fill_continuous(type = "viridis") +
#   transition_time(time) +
#   labs(title = "Ecological time: {round(frame_time)}")

movement <- read_csv("exploration_out.txt", col_names = FALSE) 
movement_data <- movement %>%
  rename(time = X1, x_pos = X2, y_pos = X3, vigilance = X4)

# movement_data %>%
#   ggplot(aes(x_pos, y_pos)) +
#   geom_jitter() +
#   theme_classic() +
#   transition_time(time) +
#   labs(title = "Ecological time: {round(frame_time)}")

gPlot <- resource_data %>%
  ggplot(aes(x, y)) +
  geom_tile(aes(fill = resource)) +
  geom_jitter(data = movement_data, 
              mapping = aes(x_pos, y_pos, color = vigilance), 
              size = 5, 
              alpha = 0.8) +
  theme(panel.grid = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) +
  scale_fill_continuous(type = "viridis") +
  scale_color_gradient(low="white", 
                       high="black") +
  transition_time(time) +
  labs(title = "Ecological time: {round(frame_time)}")

# to add a wake that follows the dots movements, add:
# shadow_wake(wake_length = 0.1) +

anim_save("grid_out.gif", gPlot)
