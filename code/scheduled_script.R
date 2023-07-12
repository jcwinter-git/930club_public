# Full playlist_build code to avoid using here package

###############################################################################
# Web scraping tool that pulls all of the "upcoming shows" from the 930's 
# website and organizes the information into a dataframe. Adds in some 
# light data cleaning, referencing the fuzzy_match.R
###############################################################################

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

# change individual band names to ID errors

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

###############################################################################
# Uses spotidy, a Spotify API wrapper to take the list of bands and identify 
# the most recent album and the most popular songs from that album
# Output is a dataframe of the playlist
###############################################################################


library(httr)
library(jsonlite)
library(spotidy)

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

# save(complete, file = here("output", "top5playlistR.Rdata"))

# write.csv(complete, here("output", "top_tracks.csv"))

###############################################################################
# Build the playlist using the tinyspotifyr library to add the top 5
# songs from the newest album of each artist to a playlist
###############################################################################

library(httr)
library(jsonlite)
library(tinyspotifyr)

# Set up access token
client_id <- "CLIENTID"
client_secret <- "CLIENTSECRET"
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)
access_token <- get_spotify_access_token()

playlist_name <- "Coming up next at the 930 Club"
playlist_description <- "Songs from upcoming shows at the 930 Club"

# Bugs: 
# I want to make this so it doesn't create the same playlist over and over, 
# but instead deletes it if there's a match and writes a new playlist

my_playlists = get_my_playlists(limit = 50)
track_uris = paste0("spotify:track:", complete$id)

# Check to see if playlist exists. If it does, clear it. 
# If it doesn't, create it
playlist_logical <- (my_playlists$name == playlist_name)
if(sum(playlist_logical) > 0){
  ind <- which(playlist_logical)
  p <- my_playlists[ind, ]
  reorder_replace_playlist_items(playlist_id = p$id, uris = "")
} else {
  p = create_playlist("USERNAME", playlist_name, public = FALSE)
}

# Can only add 100 tracks at once, need to repeat it the right # of times

for (i in 0:(floor(length(track_uris) / 100) - 1)) {
  add_tracks_to_playlist(
    playlist_id = p$id,
    uris = track_uris[(1 + 100*i):(100 + 100*i)]
  )
}
add_tracks_to_playlist(
  playlist_id = p$id,
  uris = track_uris[(floor(length(track_uris) / 99) * 100 + 1):length(track_uris)]
)
