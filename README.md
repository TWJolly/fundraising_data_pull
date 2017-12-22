# fundraising_data_pull

This script takes a table of charities and creates 2 tables with data from the justgiving api:

current_fundraisers.csv will contain all the fundraisers for all of the charities
current_donations.csv will contain all the donations to the fundraisers

It also creates some all_* files that increase in size every time you run the script - this is to capture data changes and to retain data from expired pages (which can't be accessed through the api)