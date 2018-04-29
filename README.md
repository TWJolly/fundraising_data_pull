# Charity seeding experiment code and process

## How do I make the code run?
Install the packages at the top of main.R.
Open fundraising_data_pull.Rproj using R and run main.R . 
It will take 30 - 60 mins to download all the data; this appears to be determined by Just Giving API limits.

## What are the files created?
2 files are created and 4 are updated each time data is drawn from the API.

###Created:
A table of currently live (not yet expired) pages is created in {data\just_giving_data_snapshots\fundraisers} wiht the current date appended. Only for charities with a just giving id in the effective_charities.csv file (the effective_charities.csv is in the data folder of the project).

A table of donations to currently live pages is created in {data\just_giving_data_snapshots\donations} with the current date appended.

These files are created as a record of the state of the full sample of pages. This is:
* Incase we find issues with the code or our data collection methodology during the experiment.
* For transparency - this data can be published as a way of allowing our entire process to be visible.

###Updated:
**data_pulls.csv** is updated with the date and the file paths of the 2 files created. The most recent files referenced in this table are used to update the other files.

**experimental_pages.csv** contains the page data from all of the fundraising pages that have been selected for the experiment (treatment and control)

**donations_to_experimental_pages.csv** contains all of the donations data for the pages in the experimental_pages.csv file. This will be the main source of data for testing the hypothesis

**treatments.csv** contians a list of pages that have been or should be treated. There will be a link to the page and a column inwhich the additional donation can be filled in.

## Expected experimental process

####Every 1-3 days (more often will create a larger sample size):
1. Run the main.R script
	+ This will download all the required data and split and new pages (pages that have received at least one donation but are not yet part of the experiment) into treatment and control.
	+ Treatment and control are determined by the last digit (seconds) of the time of the first donations. Even = Control. Odd = Treatment.
	+ All new pages in the treatment group are added to treatments.csv (with a 0 in the additional_donated_amount column)
2. After the script has finished running open treatments.csv in the data folder
3. Filter treatments.csv to the pages that have not yet recieved an additional donation7
4. Open each of the links in turn and donate the large additional donation to that page
5. Update the additional_donated_amount column with the additional amount donated.

The active part of the experiment will be over once we have depleted the pre-defined pot of money (and therefore also have a treatment group of pre-defined size).

####After the donation part of the experiment 

There will need to be periodic data collection due to the fact that pages can expire (we would lose access to this data). And as some pages expire after years, we will need pragmatically decide an end point to our observations. Most donations come before or immediatly after the event being fundraised for so this shouldn't be too long.

1. First we'll look at the sample of page expiry dates across both treatment and control groups.
2. Select the dates we will need to run the scripts to ensure we capture any donations pre-expiry.
3. By monitoring the rate of new donations, we can pick a stop point when we are confident that we have collected the vast majority of donation to experimental pages.
4. We will then implement our pre-defined analysis.


