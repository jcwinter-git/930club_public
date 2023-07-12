# Fuzzy match
# Runs a search of all artists scraped off upcoming shows and outputs a table
# of the artist name, the top hit, and the generalized Levenshtein distance
# where 0 is an exact match, and < 5 is usually a match. Bad matches are 
# reviewed by hand and cleaned in the web_scrape.R script

library(stringdist)
library(spotidy)
library(here)
library(httr)
library(jsonlite)

source(here("cleaning", "web_scrape.R"))

# Your Spotify application credentials
client_id <- "CLIENTID"
client_secret <- "CLIENTSECRET"
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

my_token <- get_spotify_api_token(client_id, client_secret)

# Search using the band name, create a top 20
# longlist = spotidy::search_artists(artist_name) %>%
#   select(artist, followers, popularity, artist_id) %>%
#   mutate(followers_ct = as.numeric(followers))

# Calculate distance from target name
# dist = t(adist(artist_name, spotidy::search_artists(artist_name)$artist))

# Organize
# fm = data.frame(artist_name, longlist, dist) 
# fm %>% arrange(dist, -followers_ct) 

match_dist = function(artist_name) {
  longlist = search_artists(artist_name) %>%
    select(artist, followers, popularity, artist_id) %>%
    mutate(followers_ct = as.numeric(followers))
  if(nrow(longlist > 0)) {
    fm = data.frame(artist_name, "artist" = longlist$artist, 
                    "followers" = longlist$followers_ct, 
                    "distance" = t(adist(artist_name, spotidy::search_artists(artist_name)$artist)))
    return(head(fm, 1))  
  }
}

top_match = bind_rows(lapply(df$bands, match_dist))
