# Build the playlist using the tinyspotifyr library to add the top 5
# songs from the newest album of each artist to a playlist

# load in environment
source(here::here("code", "playlist_df.R"))
# load(here("output", "top5playlistR.Rdata"))

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


