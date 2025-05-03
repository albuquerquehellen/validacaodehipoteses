SELECT
  AVG(in_spotify_playlists) AS media,
  MIN(in_spotify_playlists) AS minimo,
  MAX(in_spotify_playlists) AS maximo
 FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`
WHERE in_spotify_playlists IS NOT NULL;