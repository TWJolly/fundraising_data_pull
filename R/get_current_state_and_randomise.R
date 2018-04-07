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
  experimental_page_names <- all_experimental_pages %>%
    read_csv %>%
    pull(pageShortName)
} else{experimental_page_names <- c()}

#take latest relevant data and extract new pages 

  