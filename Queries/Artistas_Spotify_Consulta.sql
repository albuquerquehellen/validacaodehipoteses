SELECT
  AVG(artist_count) AS media,
  MIN(artist_count) AS minimo,
  MAX(artist_count) AS maximo
 FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`
WHERE artist_count IS NOT NULL;