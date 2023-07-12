# Web scraping tool that pulls all of the "upcoming shows" from the 930's 
# website and organizes the information into a dataframe. Adds in some 
# light data cleaning, referencing the fuzzy_match.R

library(stringr)
library(dplyr)
library(rvest)

# Specify the URL of the website
link <- "https://www.930.com/#upcoming-shows-container"

# Send a GET request to the URL and read the HTML content
page <- read_html(link)

# Extract the relevant information using CSS selectors
bands <- page %>%
  html_nodes("#upcoming-listview .headliners a") %>%
  html_text() %>% str_replace("\n","") %>% 
  str_squish() %>% unique()
df <- data.frame(bands, stringsAsFactors = F)

# change individual band names when there are ID errors

df[grep(pattern = "^Matt and Kim", df$bands),"bands"] = "Matt and Kim"
df[grep(pattern = "^Rodrigo y Gabriela", df$bands),"bands"] = "Rodrigo y Gabriela"
df$bands[df$bands == "Conway the Machine (NEW DATE)"] = "Conway the Machine"
df$bands[df$bands == "JVKE - what tour feels like"] = "JVKE"
df = dplyr::add_row(
  df,
  bands = "Nicholas Jamerson",
  .before = grep(pattern = "^The Vegabonds & Nicholas Jamerson", df$bands) + 1
)
df[grep(pattern = "^The Vegabonds & Nicholas Jamerson", df$bands),"bands"] = "The Vegabonds"

# Remove the DJ Night shows
exclude = c("Emo Nite",
            "Gasolina: Reggaeton Party",
            "So Fetch: All the Best Music from the '00s",
            "The Circus Life Presents",
            "Dance Yourself Clean: An Indie Electronic Dance Party",
            "Clocked Out: A 9:30 Staff Spectacular",
            "FANCY: Queens of Country Party",
            "X (POSTPONED)", 
            "Boy Pablo (CANCELED)",
            "The Taylor Party: Taylor Swift Night",
            "Giant Rooks (CANCELED)",
            "Gimme Gimme Disco: A Dance Party Inspired by ABBA",
            "Who? Weekly")
df <- subset(df, !(bands %in% exclude))

