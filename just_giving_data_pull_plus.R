library(tidyverse)
library(httr)
library(jsonlite)
library(rlist)
library(XML)

library(pacman)
#knitr,dplyr,tidyverse,labelled,citr,reporttools,magrittr,glue,huxtable,experiment,dataMaid,broom,janitor,here,xRStata,estimatr,xtable
p_load(dplyr,magrittr,purrr,tidyverse,tidyr,broom,janitor,here,glue,dataMaid,glue,readr, lubridate,summarytools) 

source("my_app_id.R") #sources the file you just created with your app id on JustGiving

charities_csv <- 'effective_charities_plus.csv' #replace with your list of preferred charities (this script currently only uses charity name and JustGiving ID)
#data_folder <- 'data\\just_giving_data' #folder where the data ends up
data_folder <- 'data\\just_giving_data_plus' #folder where the data ends up

#these file paths are defined here used to save the data at the end of this script
all_donations_file <- paste(data_folder, 'all_donations.csv', sep ='\\')
all_fundraisers_file <- paste(data_folder, 'all_fundraisers.csv', sep ='\\')
current_donations_file <- paste(data_folder, 'current_donations.csv', sep ='\\')
current_fundraisers_file <- paste(data_folder, 'current_fundraisers.csv', sep ='\\')

get_data_from_api <- function(uri_end,
                  host = 'api.justgiving.com',
                  app_id = my_app_id){
  data <- paste('https://', host, app_id, uri_end, sep = '') %>%
    httr::GET(.) %>%
    content(as = 'parsed')
  return(data)
}

list_to_tibble <- function(named_list, my_recursive = F){
    named_list %>%
    unlist(recursive = my_recursive) %>%
    as.data.frame.list %>%
    as.tibble %>%
    return
}

get_charity_fundraising_pages <- function(charity_name, id){
  charity_search_name <- gsub(' ', '%20', charity_name)
  uri <- paste('/v1/onesearch?q=', charity_search_name, '&i=Fundraiser&limit=9999', sep = '')
  print(paste('Searching for fundraisers for:', charity_name))
  charity_search_response <- get_data_from_api(uri)
  if(!is.null(charity_search_response$Total)) {
     if (charity_search_response$Total==0) {
    return(NULL)
     }
  } else {
    return(NULL)}
  fundraisers_data <- charity_search_response[['GroupedResults']][[1]][['Results']] %>%
    map(list_to_tibble) %>%
    reduce(bind_rows)%>%
    mutate(charity = charity_name,
           searched_charity_id = id)
  return(fundraisers_data)
}

get_fundraising_data <- function(fundraiser_id){
  print(paste('Getting data for fundraiser with id', fundraiser_id))
  paste('/v1/fundraising/pagebyid/',fundraiser_id, sep = '') %>%
    get_data_from_api %>%
    xmlParse %>%
    xmlToList %>%
    list_to_tibble(my_recursive = T) %>%
    return
}

get_fundraiser_donations <- function(short_page_name){
  print(paste('Getting donations from fundraiser with short name', short_page_name))
  uri <- paste('/v1/fundraising/pages/', short_page_name, '/donations', sep = '')
  donation_data_response <- get_data_from_api(uri) %>%
    xmlParse %>%
    xmlToList
  if(is.null(donation_data_response[['donations']])){
    return(NULL)
  }
  results <- donation_data_response[['donations']] %>%
    map(list_to_tibble) %>%
    reduce(bind_rows) %>%
    mutate(pageShortName = short_page_name)
  return(results)
}

charity_data <- charities_csv %>%
  read_csv %>%
  drop_na(charity_name)

fundraiser_search_data <-
  map2(charity_data$charity_name, charity_data$regno, get_charity_fundraising_pages) %>%
  reduce(bind_rows)  %>%
  mutate(EventDate=ymd_hms(EventDate,tz="GB")) %>%
  filter(year(EventDate)>2017)
  
#DR, 25 Jul 2018: Note I swapped in "regno" for "justgiving_id" because the latter is hard to find in many cases

#fundraiser_search_data_S <-filter(fundraiser_search_data,Id!="11117814",Id!="7002366",Id!="10848759",Id!="11134769",charity!="Unicef UK")
#fundraiser_search_data_X <-filter(fundraiser_search_data,Id %in% c("5145793","11117814","7002366","10848759","11134769","6598470","10847131"))
#below op does fine for a limited set of fundraisers, but hangs up on particular fundraisers, e.g., with id 11117814 or 7002366 or 5145793
#The error message is "Error in file.exists(file) : invalid 'file' argument"
#fixed by looking at only recent EventDate (see above)

fundraising_page_data <-
  map(fundraiser_search_data$Id, get_fundraising_data) %>%
  reduce(bind_rows) %>%
  left_join(fundraiser_search_data, by = c('pageId' = 'Id'))   %>%
  #filter(searched_charity_id == charity.id) %>%
  filter(charity.name == charity) %>%
  select(-grep('image.', names(.))) %>%
  select(-grep('videos.', names(.)))%>%
  select(-grep('branding.', names(.))) %>%
  mutate(date_downloaded = Sys.time()) 

fundraising_page_data_notrek <- fundraising_page_data %>%
  filter(eventId!="4447644") %>%
  filter(charity.name == charity) %>%
  filter(!grepl("Felix-Ahatty1",pageShortName))  %>%
  filter(!grepl("Sanem-Roberts",pageShortName))  %>%
  arrange(desc(eventDate))

donation_data <-
  map(fundraising_page_data_notrek$pageShortName, get_fundraiser_donations) %>%
  reduce(bind_rows) %>%
  mutate(date_downloaded = Sys.time())

if(file.exists(all_fundraisers_file)){
  write_csv(fundraising_page_data, all_fundraisers_file, append = T)
} else(write_csv(fundraising_page_data, all_fundraisers_file))
if(file.exists(all_donations_file)){
  write_csv(donation_data, all_donations_file, append = T)
} else(write_csv(donation_data, all_donations_file))
write_csv(fundraising_page_data, current_fundraisers_file)
write_csv(donation_data, current_donations_file)

fundraising_page_data_L <- fundraising_page_data %>% 
  group_by(charity.id) %>% 
  summarise(c = names(table(charity))[which.max(table(charity))])


