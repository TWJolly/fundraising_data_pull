latest_data_pulls <- table_of_data_pulls %>%
  read_csv %>%
  filter(datetime == max(datetime))

latest_donations <- latest_data_pulls %>%
  pull(donations_file_path) %>%
  read_csv

latest_fundraisers <- latest_data_pulls %>%
  pull(fundraisers_file_path) %>%
  read_csv

latest_relevant_donations_data <- latest_donations %>%
  group_by(pageShortName) %>%
  summarise(total_raised = sum(amount, na.rm = T),
            donation_count = length(amount),
            first_donation_date = min(donationDate),
            first_donation_amount = amount[which(donationDate == min(donationDate))],
            average_donation = mean(amount, na.rm = T))

latest_relevant_data <- latest_fundraisers %>%
  select(pageShortName, charity, fundraisingTarget,expiryDate) %>%
  left_join(latest_relevant_donations_data)

if(file.exists(all_experimental_pages)){
  previous_experimental_pages <- all_experimental_pages %>%
    read_csv
  experimental_page_names <- pull(previous_experimental_pages, pageShortName)
} else{experimental_page_names <- c()}

randomisation_protocol <- function(first_donation_date){
    first_donation_second <- lubridate::second(first_donation_date)
    group <- ifelse(first_donation_second%%2==1,'Treatment', 'Control') #Odd = treatment, Even = control
    return(group)
    }

new_pages <- latest_relevant_data %>%
  filter(!(pageShortName %in% experimental_page_names)) %>%
  filter(!is.na(first_donation_date)) %>%
  filter(first_donation_date >=experiment_start_date) %>%
  mutate(group = randomisation_protocol(first_donation_date),
         date_identified = date)

if(file.exists(all_experimental_pages)){
  experimental_pages <-  bind_rows(previous_experimental_pages, new_pages)
  write_csv(experimental_pages, all_experimental_pages)
}else(write_csv(new_pages, all_experimental_pages))


  