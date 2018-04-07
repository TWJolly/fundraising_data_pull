library(tidyverse)
library(httr)
library(jsonlite)
library(rlist)
library(XML)

charities_csv <- 'effective_charities.csv' #replace with your list of preferred charities (this script currently only uses charity name and JustGiving ID)
data_folder <- 'data'
snapshots_folder <- file.path(data_folder, 'just_giving_data_snapshots') #folder where the data ends up

#these file paths are defined here used to save the data at the end of this script
date = Sys.Date()
time = Sys.time()
donations_file <- paste('donations', date, '.csv', sep = '')
fundraisers_file <- paste('fundraisers', date, '.csv', sep = '')
donations_folder <- file.path(snapshots_folder, 'donations')
fundraisers_folder <- file.path(snapshots_folder, 'fundraisers')
current_donations_file <- file.path(donations_folder, donations_file)
current_fundraisers_file <- file.path(fundraisers_folder, fundraisers_file)
all_experimental_pages <- file.path(data_folder, 'experimental_pages.csv')
table_of_data_pulls <- file.path(data_folder, 'data_pulls.csv')

source("my_app_id.R") #sources the file you just created with your app id on JustGiving
source("functions.R")
source("just_giving_data_pull.R")
source("get_current_state_and_randomise.R")