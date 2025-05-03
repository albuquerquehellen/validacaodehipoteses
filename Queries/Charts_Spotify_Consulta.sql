SELECT
  AVG(in_spotify_charts) AS media,
  MIN(in_spotify_charts) AS minimo,
  MAX(in_spotify_charts) AS maximo
 FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`
WHERE in_spotify_charts IS NOT NULL;