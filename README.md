# fundraising_data_pull

## What does this do?
This script (just_giving_data_pull.R) takes a table of charities and creates 2 tables with data from the justgiving api:

current_fundraisers.csv will contain all the fundraisers for all of the charities listed in the table
current_donations.csv will contain all the donations to these fundraisers
- Note that the column "Link" gives the URL for the fundraisers themselves

It also creates/appends data to  2 all_* files in the present folder that increase in size every time you run the script - this is to capture data changes and to retain data from expired pages (which can't be accessed through the api).

The charities that this script uses (in effective_charities.csv) are all recommended by one or more organisations associated with effective altruism (although in some cases the lists only recommend targeting a particular part of the charity's work):

https://www.givewell.org/

https://www.thelifeyoucansave.org/

https://ea-foundation.org/

https://animalcharityevaluators.org/

(Note: we also give a broader list in the file effective_charities_plus, including some additional international mega-charities like MSF)

## How do I make it run?

<a href="https://developer.justgiving.com/" target="_blank">Register here</a>

You will first need to register a justgiving api here (https://developer.justgiving.com/). This will provide you with an app id.
Create a file called my_app_id.R with the following contents (include the slash, do not include the brackets):

my_app_id <- {/your app id}

#You may need to add quotes around this, i.e., my_app_id <- "/id_number"


##Next, run Just_giving_data_pull.R
