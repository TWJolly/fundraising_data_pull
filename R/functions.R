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
  if(charity_search_response$Total == 0){
    return(NULL)
  }
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