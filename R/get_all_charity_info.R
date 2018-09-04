
#This script creates a dataset of all charities on JustGiving

limit = 15000
uri_end <- paste("/v1/onesearch?q=*&i=charity&limit=", limit, sep = "")
api_call_results <- get_data_from_api(uri_end)

charities <- api_call_results$GroupedResults[[1]]$Results

charity_df <-map(charities, list_to_tibble) %>%
  reduce(bind_rows)%>%
  mutate(regno = str_extract(Subtext,"([:alpha:]{2})?[:digit:]+"))

write_csv(charity_df, full_jg_charity_list)

####Get all the fundraising info - this will take ages####

all_jg_fundraiser_search_data <-
  map2(charity_df$Name, charity_df$regno, get_charity_fundraising_pages) %>%
  reduce(bind_rows)



