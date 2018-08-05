#This script downloads all current data for the target charities, 
#It also saves a snapshot

#Get table of target charities
charity_data <- charities_csv %>%
  read_csv %>%
  drop_na(charity_name, regno)

#Get all fundraisers for target charities (just basic information)
fundraiser_search_data <-
  map2(charity_data$charity_name, charity_data$regno, get_charity_fundraising_pages) %>%
  reduce(bind_rows)

#Sample of 50 for testing... fundraiser_search_data <- tail(fundraiser_search_data,n=50)
  
#Get info about the fundraisers
fundraising_page_data <-
  map(fundraiser_search_data$Id, get_fundraising_data) %>%
  reduce(bind_rows) %>%
  left_join(fundraiser_search_data, by = c('pageId' = 'Id')) %>%
  filter(searched_charity_id == charity.registrationNumber) %>% #match the 'regno' 
  select(-grep('image.', names(.))) %>%
  select(-grep('videos.', names(.)))%>%
  select(-grep('branding.', names(.))) %>%
  mutate(date_downloaded = Sys.time())

#Get all current donations on the fundraising pages
donation_data <-
  map(fundraising_page_data$pageShortName, get_fundraiser_donations) %>%
  reduce(bind_rows) %>%
  mutate(date_downloaded = Sys.time())

#Creates snapshot folders if they don't already exist
dir.create(snapshots_folder, showWarnings = FALSE)
dir.create(donations_folder, showWarnings = FALSE)
dir.create(fundraisers_folder, showWarnings = FALSE)

write_csv(fundraising_page_data, current_fundraisers_file)
write_csv(donation_data, current_donations_file)

#The code  below creates a table of data pull events. So that the most recents data is used and we retain a record of our behaviour
this_data_pull <- data.frame(date, time)
names(this_data_pull) <- c('date', 'datetime')
this_data_pull <- this_data_pull %>%
  mutate(donations_file_path = current_donations_file,
         fundraisers_file_path = current_fundraisers_file)

if(file.exists(table_of_data_pulls)){
  data_pulls <- read_csv(table_of_data_pulls)
  data_pulls <- bind_rows(data_pulls, this_data_pull) 
} else(data_pulls <- this_data_pull)
write_csv(data_pulls, table_of_data_pulls)