# 930club_public
Creates a Spotify playlist of the top songs from artists coming to the 9:30 club. Updates weekly.
Thank you to the authors of the spotidy and tinyspotifyr packages. Their packages were invaluable.
Spotify playlist link: https://open.spotify.com/playlist/1U8jEwTCSBZt2Gc0Ir8KvG?si=e5c15cc9092740fa

If you're interested in replicating this at other concert venues, here are a 
few helpful steps. First, register with the Spotify API. This gives you 
client ID and client secret keys. After that, find your spotify username. 

In lines: 67-68, 127-128, and 151 of scheduled_script.R you'll need to 
fill those pieces in. Each webscrape will require different levels of cleaning, 
but you'll have the lowest burden for large venues with popular artists


