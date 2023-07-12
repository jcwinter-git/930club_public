# install.packages("httr")
# install.packages("jsonlite")
#install.packages("spotidy")

# Uses spotidy, a Spotify API wrapper to take the list of bands and identify 
# the most recent album and the most popular songs from that album
# Output is a dataframe of the playlist

library(httr)
library(jsonlite)
library(spotidy)
library(here)

source(here("cleaning", "web_scrape.R"))

# Spotify API endpoint for obtaining an access token
# auth_url <- "https://accounts.spotify.com/api/token"

# Your Spotify application credentials
client_id <- "CLIENTID"
client_secret <- "CLIENTSECRET"
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

# access_token <- get_spotify_access_token()

# get_spotify_access_token(client_id = client_id, client_secret = client_secret)

# Load two tokens, and specify them in-line which to use
# tiny_token <- get_spotify_access_token(client_id, client_secret)
my_token <- get_spotify_api_token(client_id, client_secret)

# Bugs: 
# Some artists are a perfect match, but Spotidy search pulls diff name (Melt)

build_playlist <- function(i) { # create a function with the name my_function
  artist_name <- df$bands[i]
  
  # Hard code one problematic artist
  if (artist_name == "Melt") {
    artist_id = "0G7KI9I5BApiXc5Sqpyil9"
  } else {
  artist_id = search_artists(artist_name)$artist_id[1]
  }
  
  if (is.na(artist_id) == F) {
    album_info = get_artist_albums(artist_id,)
    new_album = album_info$album_id[1]
    new_tracks = get_album_tracks(new_album)$track_id
    list = lapply(new_tracks, FUN = get_tracks)
    top5 = list %>% bind_rows %>% arrange(-popularity) %>% head(5)
    artist = top5$artist_name
    album = rep(album_info$album[1], length(artist))
    title = top5$track
    track_id = top5$track_id
    playlist = list(artist = artist, album = album, title = title, id = track_id)
    return(playlist)
  }
}

# 2.9 minutes
# start_time <- Sys.time()
complete = bind_rows(lapply(1:length(df$bands), FUN = build_playlist))
# Sys.time()-start_time

save(complete, file = here("output", "top5playlistR.Rdata"))

# write.csv(complete, here("output", "top_tracks.csv"))

